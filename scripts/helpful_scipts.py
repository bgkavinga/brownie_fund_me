from brownie import network, accounts, config, MockV3Aggregator
from web3 import Web3

DECIMALS = 8
STARTING_PRICE = 200000000000
FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]


def get_account():
    active_network = network.show_active()
    print(f"Active network %s" % active_network)
    if active_network in LOCAL_BLOCKCHAIN_ENVIRONMENTS or network.show_active() in FORKED_LOCAL_ENVIRONMENTS:
        account = accounts[0]
    else:
        account = accounts.add(config["wallets"]["from_key"])
    print(f"account address {account.address}")
    return account


def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print("deploying mocks...")
    if len(MockV3Aggregator) <= 0:
        MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": get_account()})
        print("mocks deployed!")
