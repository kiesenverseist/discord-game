import asyncio

from bot import MyClient
from ws import ws

send_q = asyncio.Queue()
recv_q = asyncio.Queue()

loop = asyncio.new_event_loop()
asyncio.set_event_loop(loop)

bot_client = MyClient(loop = loop)
bot_client.queues(send_q, recv_q)

ws_client = ws(loop, send_q, recv_q)

bot_task = asyncio.ensure_future(bot_client.run('Mjk5ODg2MTcxOTQzNzMxMjAw.XLGm2A.ytEKFiSHFYtRFgjPa1y2VNNwsew'))
ws_task = asyncio.ensure_future(ws_client.run())

done, pending = asyncio.wait(
    [ws_task, bot_task],
    return_when=asyncio.FIRST_COMPLETED,
)
for task in pending:
    task.cancel()