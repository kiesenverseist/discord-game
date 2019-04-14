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

    async def send_messages(self):
        await self.wait_until_ready()
        channel = self.get_channel(566610532786765854) # channel ID goes here
        while not self.is_closed():
            if not self.recv_q.empty():
                await channel.send(str(self.recv_q.get()))
            await asyncio.sleep(1)

    async def on_message(self, message):
        # we do not want the bot to reply to itself
        if message.author.id == self.user.id:
            return

        if message.channel.id == 566610532786765854:
            self.send_q.put(str(message.content))