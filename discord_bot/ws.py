import asyncio
import queue
import websockets
import json

class ws():   
    def __init__(self, send, recv):
        self.send_q = send
        self.recv_q = recv
    
    async def consumer(self, message):
        msg = json.loads(message)
        print(f'>{message}')
        self.recv_q.put(msg)
    
    async def producer(self):
        if not self.send_q.empty():
            msg = self.send_q.get()
            print("<" +str(msg))
            msg = json.dumps(msg)
            return msg
    
    async def consumer_handler(self, websocket, path):
        try:
            async for message in websocket:
                await self.consumer(message)
        finally:
            await self.consumer(json.dumps({"type":"message", "message":"Server Closed", "channel_id" : "566610532786765854"}))

    async def producer_handler(self, websocket, path):
        while True:
            message = await self.producer()

            if message:
                await websocket.send(message)
            await asyncio.sleep(0.1)

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

        start_server = websockets.serve(self.handler, 'localhost', 8080)

        asyncio.get_event_loop().run_until_complete(start_server)
        asyncio.get_event_loop().run_forever()