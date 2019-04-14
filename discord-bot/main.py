import asyncio
import queue
import threading

from bot import MyClient
from ws import ws

send_q = queue.SimpleQueue()
recv_q = queue.SimpleQueue()

bot_client = MyClient()
bot_client.queues(send_q, recv_q)

ws_client = ws(send_q, recv_q)

bot_worker = threading.Thread(target=bot_client.run, args=('Mjk5ODg2MTcxOTQzNzMxMjAw.XLGm2A.ytEKFiSHFYtRFgjPa1y2VNNwsew',))
ws_worker = threading.Thread(target=ws_client.run)

bot_worker.start()
ws_worker.start()