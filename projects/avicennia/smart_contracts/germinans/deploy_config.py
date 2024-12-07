import logging

import algokit_utils
from algosdk.v2client.algod import AlgodClient
from algosdk.v2client.indexer import IndexerClient

logger = logging.getLogger(__name__)


# define deployment behaviour based on supplied app spec
def deploy(
    algod_client: AlgodClient,
    indexer_client: IndexerClient,
    app_spec: algokit_utils.ApplicationSpecification,
    deployer: algokit_utils.Account,
) -> None:
    from smart_contracts.artifacts.germinans.germinans_client import (
        Certificate,
        CertificateDetails,
        GerminansClient,
    )

    app_client = GerminansClient(
        algod_client,
        creator=deployer,
        indexer_client=indexer_client,
    )

    app_client.deploy(
        on_schema_break=algokit_utils.OnSchemaBreak.AppendApp,
        on_update=algokit_utils.OnUpdate.AppendApp,
    )

    response = app_client.initalize(
        details=CertificateDetails(
            name="Jammmmm",
            organization="James",
            organization_unit="James Brown",
            country="Funkland",
            province="Mothership",
            locality="Right there",
        ),
        cert=Certificate(
            public="---wow", private="hello", revocation_list="takes more"
        ),
    )
    logger.info(
        f"Called initalize on {app_spec.contract.name} ({app_client.app_id}) \n"
        f"{response.return_value}"
    )
