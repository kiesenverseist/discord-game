import asyncio
import queue
import threading

from bot import MyClient
from ws import ws

send_q = queue.SimpleQueue()
recv_q = queue.SimpleQueue()

bot_client = MyClient(send=send_q, recv=recv_q, heartbeat_timeout=5)
ws_client = ws(send_q, recv_q)

ws_worker = threading.Thread(target=ws_client.run)
ws_worker.setDaemon(True)
ws_worker.name = "ws thread"

ws_worker.start()

bot_client.run('Mjk5ODg2MTcxOTQzNzMxMjAw.XLGm2A.ytEKFiSHFYtRFgjPa1y2VNNwsew')

print("bot closed")