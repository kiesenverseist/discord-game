import asyncio
import queue
import discord
import random

class MyClient(discord.Client):
    def queues(self, send, recv):
        self.send_q = send
        self.recv_q = recv

        # self.bg_task = self.loop.create_task(self.send_messages())

    async def on_ready(self):
        print('------')
        print('Logged in as')
        print(self.user.name)
        print(self.user.id)
        print('------')

    async def send_messages(self):
        await self.wait_until_ready()
        channel = self.get_channel(566610532786765854) # channel ID goes here
        while not self.is_closed():
            msg = await self.recv_q.get()
            await channel.send(str(msg))

    async def on_message(self, message):
        # we do not want the bot to reply to itself
        if message.author.id == self.user.id:
            return

        if message.channel.id == 566610532786765854:
            await self.send_q.put(str(message.content))