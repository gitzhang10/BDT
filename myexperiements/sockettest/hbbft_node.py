import random
import gevent
import os
import pickle
from typing import  Callable
from gevent import time
from honeybadgerbft.core.honeybadger import HoneyBadgerBFT
from myexperiements.sockettest.make_random_tx import tx_generator
from multiprocessing import Value as mpValue, Queue as mpQueue, Process
from ctypes import c_bool


def load_key(id):

    with open(os.getcwd() + '/keys/' + 'sPK.key', 'rb') as fp:
        sPK = pickle.load(fp)

    with open(os.getcwd() + '/keys/' + 'ePK.key', 'rb') as fp:
        ePK = pickle.load(fp)

    with open(os.getcwd() + '/keys/' + 'sSK-' + str(id) + '.key', 'rb') as fp:
        sSK = pickle.load(fp)

    with open(os.getcwd() + '/keys/' + 'eSK-' + str(id) + '.key', 'rb') as fp:
        eSK = pickle.load(fp)

    return sPK, ePK, sSK, eSK


class HoneyBadgerBFTNode (HoneyBadgerBFT):

    def __init__(self, sid, id, B, N, f, bft_from_server: Callable, bft_to_client: Callable, ready: mpValue, stop: mpValue, K=3, mode='debug', mute=False, bft_running: mpValue=mpValue(c_bool, False), tx_buffer=None):
        self.sPK, self.ePK, self.sSK, self.eSK = load_key(id)
        self.bft_from_server = bft_from_server
        self.bft_to_client = bft_to_client
        self.send = lambda j, o: self.bft_to_client((j, o))
        self.recv = lambda: self.bft_from_server()
        self.ready = ready
        self.stop = stop
        self.mode = mode
        self.running = bft_running
        HoneyBadgerBFT.__init__(self, sid, id, B, N, f, self.sPK, self.sSK, self.ePK, self.eSK, self.send, self.recv, K=K, mute=mute)

    def prepare_bootstrap(self):
        self.logger.info('node id %d is inserting dummy payload TXs' % (self.id))
        if self.mode == 'test' or 'debug':
            tx = tx_generator(250) # Set each dummy TX to be 250 Byte
            k = 0
            for _ in range(self.K):
                for r in range(self.B):
                    HoneyBadgerBFT.submit_tx(self, tx.replace(">", hex(r) + ">"))
                    k += 1
                    if r % 50000 == 0:
                        self.logger.info('node id %d just inserts 50000 TXs' % (self.id))
        else:
            pass
            # TODO: submit transactions through tx_buffer
        self.logger.info('node id %d completed the loading of dummy TXs' % (self.id))

    def run(self):

        pid = os.getpid()
        self.logger.info('node %d\'s starts to run consensus on process id %d' % (self.id, pid))

        self.prepare_bootstrap()

        while not self.ready.value:
            time.sleep(1)

        self.running.value = True
        self.run_bft()
        self.stop.value = True

def main(sid, i, B, N, f, addresses, K):
    badger = HoneyBadgerBFTNode(sid, i, B, N, f, addresses, K)
    badger.run_bft()


if __name__ == '__main__':

    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--sid', metavar='sid', required=True,
                        help='identifier of node', type=str)
    parser.add_argument('--id', metavar='id', required=True,
                        help='identifier of node', type=int)
    parser.add_argument('--N', metavar='N', required=True,
                        help='number of parties', type=int)
    parser.add_argument('--f', metavar='f', required=True,
                        help='number of faulties', type=int)
    parser.add_argument('--B', metavar='B', required=True,
                        help='size of batch', type=int)
    parser.add_argument('--K', metavar='K', required=True,
                        help='rounds to execute', type=int)
    args = parser.parse_args()

    # Some parameters
    sid = args.sid
    i = args.id
    N = args.N
    f = args.f
    B = args.B
    K = args.K

    # Random generator
    rnd = random.Random(sid)

    # Nodes list
    host = "127.0.0.1"
    port_base = int(rnd.random() * 5 + 1) * 10000
    addresses = [(host, port_base + 200 * i) for i in range(N)]
    print(addresses)

    main(sid, i, B, N, f, addresses, K)
