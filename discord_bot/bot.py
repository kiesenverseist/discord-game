import asyncio
import queue
import discord
import random

class MyClient(discord.Client):
    def queues(self, send, recv):
        self.send_q = send
        self.recv_q = recv

        self.bg_task = self.loop.create_task(self.send_messages())

    async def on_ready(self):
        print('Logged in as')
        print(self.user.name)
        print(self.user.id)
        print('------')

        ch = self.get_channel(566610532786765854)
        await ch.send("Beep Boop \nBot Active")
        
        self.gld = self.get_guild(566545531665383424)

    async def send_messages(self):
        await self.wait_until_ready()
        while not self.is_closed():
            while not self.recv_q.empty():
                data = self.recv_q.get()

                if data["type"] == "message":
                    channel = self.get_channel(int(data.get("channel_id", 566610532786765854)))
                    await channel.send(data["message"])
                
                if data["type"] == "set_role":
                    user = self.gld.get_member(int(data["user_id"]))
                    role = self.gld.get_role(int(data["role_id"]))
                    await user.add_roles(role)

                if data["type"] == "clear_channel": #does not work
                    ch = self.get_channel(int(data["channel_id"]))
                    async for m in ch.history():
                        await m.delete()
                
                if data["type"] == "replace_last":
                    ch = self.get_channel(int(data["channel_id"]))
                    msg = ch.last_message
                    if msg != None:
                        await msg.edit(content=data["message"])
                    else:
                        await ch.send(data["message"])
        
            await asyncio.sleep(0.1)

    async def on_member_join(self, member):
        data = {}
        data["type"] = "member_join"
        data["user_id"] = str(member.id)
        data["user_name"] = member.name

        self.send_q.put(data)
    
    async def on_member_remove(self, member):
        data = {}
        data["type"] = "member_left"
        data["user_id"] = str(member.id)
        data["user_name"] = member.name

        self.send_q.put(data)

    async def on_message(self, message):
        # we do not want the bot to reply to itself
        if message.author.id == self.user.id:
            return
        
        data = {}
        data["type"] = "message"
        data["message"] = message.content
        data["user_id"] = str(message.author.id)
        data["user_name"] = message.author.name
        data["channel_id"] = str(message.channel.id)
        data["is_dm"] = isinstance(message.channel, discord.DMChannel)
        if not data["is_dm"]:
            data["channel_name"] = message.channel.name
            data["category_id"] = str(message.channel.category_id)
            data["category_name"] = message.channel.category.name

        self.send_q.put(data)