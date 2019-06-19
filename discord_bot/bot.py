import asyncio
import queue
import discord
import random

class MyClient(discord.Client):
    def __init__(self, send, recv, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.send_q = send
        self.recv_q = recv

        self.bg_task = self.loop.create_task(self.send_messages())

        self.indexed_channels = {}
        self.indexed_roles = {}

    ## EVENT FUNCTIONS
    async def on_ready(self):
        print('------')
        print('Logged in as')
        print(self.user.name)
        print(self.user.id)
        print('------')
        
        self.gld = self.get_guild(566545531665383424)

        await self.index_channels()
        await self.index_roles()

        print(self.indexed_channels["Super"]["bridge"])
        ch = self.get_channel(int(self.indexed_channels["Super"]["bridge"]))
        await ch.send("Beep Boop \nBot Active")

    async def send_messages(self):
        await self.wait_until_ready()
        while not self.is_closed():
            while not self.recv_q.empty():
                data = self.recv_q.get()

                if data["type"] == "message":
                    if not "channel_name" in data: #if the channel name is not soecified, the id will be
                        channel = self.get_channel(int(data.get("channel_id", self.indexed_channels["Super"]["bridge"])))
                        await channel.send(data["message"])
                    else:
                        channel_id = self.indexed_channels[data["category_name"]][data["channel_name"]]
                        channel = self.get_channel(int(channel_id))
                        await channel.send(data["message"])

                if data["type"] == "set_role":
                    user = self.gld.get_member(int(data["user_id"]))
                    role = None
                    if "role_name" in data:
                        role_id = int(self.indexed_roles[data["role_name"]])
                        role = self.gld.get_role(role_id)
                    else:
                        role = self.gld.get_role(int(data["role_id"]))
                    await user.add_roles(role)

                if data["type"] == "clear_channel": #does not work
                    ch = self.get_channel(int(data["channel_id"]))
                    async for m in ch.history():
                        await m.delete()
                
                if data["type"] == "replace_last":
                    if not "channel_name" in data: #if the channel name is not soecified, the id will be
                        ch = self.get_channel(int(data.get("channel_id", 566610532786765854)))
                    else:
                        channel_id = self.indexed_channels[data["category_name"]][data["channel_name"]]
                        ch = self.get_channel(int(channel_id))
                    
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

    async def on_guild_channel_delete(self, channel):
        await self.index_channels()
    
    async def on_guild_channel_create(self, channel):
        await self.index_channels()
    
    async def on_guild_channel_update(self, before, after):
        await self.index_channels()
    
    async def on_guild_role_delete(self, role):
        await self.index_roles()
    
    async def on_guild_role_create(self, role):
        await self.index_roles()
    
    async def on_guild_role_update(self, before, after):
        await self.index_roles()

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
    
    ## UTIL FUNCTIONS
    async def index_channels(self):
        all_channels = self.gld.by_category()

        self.indexed_channels = {}

        for t in all_channels:
            if t[0] == None:
                cat = "Misc"
                cat_id = "0"
            else:
                cat = str(t[0])
                cat_id = t[0].id
            
            self.indexed_channels[cat] = {"category_id" : cat_id}

            for c in t[1]:
                chan = str(c)
                chan_id = c.id
                self.indexed_channels[cat][chan] = chan_id
        
        print(self.indexed_channels)

    async def index_roles(self):
        self.indexed_roles = {}

        all_roles = self.gld.roles
        for role in all_roles:
            self.indexed_roles[str(role)] = role.id
        
        print(self.indexed_roles)
