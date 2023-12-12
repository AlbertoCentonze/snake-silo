# SILO: hardcoding factory since there aren't multiple versions
factory: public(SiloFactory)

bridge_pool: public(address)

get_silo: public(HashMap[address, address])
silo_reverse: public(HashMap[address, address])

@external
def __init__(factory: SiloFactory):
    # SILO: minimal constructor to initialize hardcoded factory
    self.factory = factory

interface SiloFactory:
    def create_silo(silo_asset: address, silo_data: Bytes[1000]) -> address: nonpayable

interface Silo:
    def sync_bridge_assets(): nonpayable

# VYPER: upperbound for bytes necessary
@internal
def _create_silo(silo_asset: address, asset_is_a_bridge: bool, silo_data: Bytes[1000]) -> address:
        # SILO: removed default version logic for now, should be back with #6

        # SILO removed factory versions

        if self.factory.address == empty(address):
            raise "Invalid Silo Version"

        created_silo: address = self.factory.create_silo(silo_asset, silo_data)

        self.get_silo[silo_asset] = created_silo
        self.silo_reverse[created_silo] = silo_asset

        Silo(created_silo).sync_bridge_assets()

        if asset_is_a_bridge: 
            self.bridge_pool = created_silo

        return created_silo