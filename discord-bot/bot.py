import asyncio
import queue
import threading
import websockets
import discord
import random

global send_q
send_q = queue.SimpleQueue()

class ws():
    global send_q

    def __init__(self):
        pass
    
    async def consumer(self, message):
        print(f'>{message}')
    
    async def producer(self):
        if not send_q.empty():
                msg = send_q.get()
                print(msg)
                return msg
    
    async def consumer_handler(self, websocket, path):
        async for message in websocket:
            await self.consumer(message)

    async def producer_handler(self, websocket, path):
        while True:
            message = await self.producer()

            if message:
                await websocket.send(message)

    async def handler(self, websocket, path):
        consumer_task = asyncio.ensure_future(
            self.consumer_handler(websocket, path))
        producer_task = asyncio.ensure_future(
            self.producer_handler(websocket, path))
        done, pending = await asyncio.wait(
            [consumer_task, producer_task],
            return_when=asyncio.FIRST_COMPLETED,
        )
        for task in pending:
            task.cancel()
    
    def run(self):
        loop=asyncio.new_event_loop()
        asyncio.set_event_loop(loop)

        start_server = websockets.serve(self.handler, '127.0.0.1', 5678)

        asyncio.get_event_loop().run_until_complete(start_server)
        asyncio.get_event_loop().run_forever()

class MyClient(discord.Client):
    global send_q

    async def on_ready(self):
        print('Logged in as')
        print(self.user.name)
        print(self.user.id)
        print('------')

    async def on_message(self, message):
        # we do not want the bot to reply to itself
        if message.author.id == self.user.id:
            return

        if message.channel.id == 566610532786765854:
            send_q.put(str(message.content))

        if message.content.startswith('$guess'):
            await message.channel.send('Guess a number between 1 and 10.')

            def is_correct(m):
                return m.author == message.author and m.content.isdigit()

            answer = random.randint(1, 10)

            try:
                guess = await self.wait_for('message', check=is_correct, timeout=5.0)
            except asyncio.TimeoutError:
                return await message.channel.send('Sorry, you took too long it was {}.'.format(answer))

            if int(guess.content) == answer:
                await message.channel.send('You are right!')
            else:
                await message.channel.send('Oops. It is actually {}.'.format(answer))

bot_client = MyClient()
ws_client = ws()

bot_worker = threading.Thread(target=bot_client.run, args=('Mjk5ODg2MTcxOTQzNzMxMjAw.XLGm2A.ytEKFiSHFYtRFgjPa1y2VNNwsew',))
ws_worker = threading.Thread(target=ws_client.run)

bot_worker.start()
ws_worker.start()