import typing

from algopy import Application, ARC4Contract, String, UInt64, subroutine
from algopy.arc4 import abimethod

################################ TYPES ################################


class Certificate(typing.NamedTuple):
    """x.509 Certificate Pair (CRT/Key)

    Current: https://datatracker.ietf.org/doc/html/rfc5280

    Attributes
    ----------
    public : String
        The public certificate file (CRT)
    private : String
        The private key information (KEY)
        TODO: Clever way to handle this private key file
    revoction_list : String
        Certificate Revoction List(CRL)
        https://datatracker.ietf.org/doc/html/rfc5280
        Note, look into: https://datatracker.ietf.org/doc/html/rfc2560
    """

    public: String
    private: String
    revocation_list: String


class SigningRequest(typing.NamedTuple):
    """x.509 Certificate Signing Request (CSR)
    TODO: everything here is just
    Attributes
    ----------
    csr : String
        The certificate signing request
    challenge : String
        A challenge provided by a source of randomness
    """

    csr: String
    # TODO: Get bytes from VRF
    challenge: String


class Metrics(typing.NamedTuple):
    requests: UInt64  # Counter for number of client certificate requests received
    issued: UInt64  # Counter for number of client certificates issued
    revoked: UInt64  # Counter for number of client certificates revoked


class CertificateDetails(typing.NamedTuple):
    name: String  # Common Name (CN)
    organization: String  # Organiztion (O)
    organization_unit: String  # Organization Unit (OU)
    country: String  # Country (C)
    province: String  # Province (ST)
    locality: String  # Locality (L)


class Intermediary(typing.NamedTuple):
    """x.509 Intermediary Certifiacte Authority (ICA)"""

    root: UInt64  # Root CA Contract (ie Germinans)
    revocation_list: String
    details: CertificateDetails  # Information about the Certificate
    cert: Certificate  # Certificate Bytes
    metrics: Metrics  # Contract Counters


class Root(typing.NamedTuple):
    """x.509 Root Certificate Authority (CA)"""

    revocation_list: String
    details: CertificateDetails
    cert: Certificate  # Certificate Bytes
    metrics: Metrics  # Contract Counters


################################ CONTRACTS ################################


class CertificateAuthority(ARC4Contract):
    """
    Certificate Authority(CA)

    Base contract for Root and Intermediary Certificate Authorities.
    It contains adapters for the different NamedTuples for easy of use.

    Certificate:
    ------------
    public: String
        Certificate Bytes
    private: String
        Private key bytes

    Details:
    -----------
    name: String
        Common Name (CN)
    organization: String
        Organiztion (O)
    organization_unit: String
        Organization Unit (OU)
    country: String
        Country (C)
    province: String
        Province (ST)
    locality: String
        Locality (L)

    Metrics:
    --------
    requests: int
        Metrics counter for number of client certificate requests received
    issued: int
        Metrics counter for number of client certificates issued
    revoked: int
        Metrics counter for number of client certificates revoked
    """

    # Certificate
    public: String  # Certificate Bytes
    private: String  # Certificate Bytes
    revocation_list: String  # Certififacte Revocation List

    # Certificate Details
    name: String  # Common Name (CN)
    organization: String  # Organiztion (O)
    organization_unit: String  # Organization Unit (OU)
    country: String  # Country (C)
    province: String  # Province (ST)
    locality: String  # Locality (L)

    # Metrics
    requests: UInt64  # Counter for number of client certificate requests received
    issued: UInt64  # Counter for number of client certificates issued
    revoked: UInt64  # Counter for number of client certificates revoked

    @subroutine
    def get_metrics(self) -> Metrics:
        return Metrics(issued=self.issued, revoked=self.revoked, requests=self.requests)

    @subroutine
    def set_details(self, info: CertificateDetails) -> None:
        self.name = info.name
        self.organization = info.organization
        self.organization_unit = info.organization_unit
        self.country = info.country
        self.province = info.province
        self.locality = info.locality

    @subroutine
    def get_details(self) -> CertificateDetails:
        return CertificateDetails(
            name=self.name,
            organization=self.organization,
            organization_unit=self.organization_unit,
            country=self.country,
            province=self.province,
            locality=self.locality,
        )

    @subroutine
    # TODO: Handle certificates in a clever way
    def get_certificate(self) -> Certificate:
        return Certificate(
            public=self.public,
            private=self.private,
            revocation_list=self.revocation_list,
        )

    @subroutine
    # TODO: Handle certificates in a clever way
    def set_certificate(self, cert: Certificate) -> None:
        self.public = cert.public
        self.private = cert.private
        self.revocation_list = cert.revocation_list


class Propagule(CertificateAuthority):
    """
    Intermediary Certificate Authority(ICA)

    Responsible for issuing client certificates and registering with the Root CA

    Attributes:
    -----------
    root: Application
        Root CA Contract (ie Germinans instance that implements CertificateAuthority)
    """

    root: Application  # Root CA Contract (ie Germinans)

    # TODO: Clear and Approvals

    @abimethod()
    def initalize(
        self,
        root: Application,
        cert: Certificate,
        details: CertificateDetails,
    ) -> Intermediary:
        # Save details
        self.set_certificate(cert)
        self.set_details(details)
        self.root = root

        # Metrics
        self.requests = UInt64(0)
        self.issued = UInt64(0)
        self.revoked = UInt64(0)

        return self.get()

    @abimethod()
    def sign(self) -> bool:
        return True

    @abimethod()
    def revoke(self, cert_id: String) -> bool:
        self.revoked += 1
        return True

    @abimethod()
    def renew(self, cert_id: String) -> bool:
        self.issued += 1
        return True

    @subroutine
    def get(self) -> Intermediary:
        return Intermediary(
            root=self.root.id,
            revocation_list=self.revocation_list,
            details=self.get_details(),
            cert=self.get_certificate(),
            metrics=self.get_metrics(),
        )


class Germinans(CertificateAuthority):
    """
    Root Certificate Authority(CA)

    Handles authorization of Intermediary Certificate Authorities(ICA)
    by represnting them as Propagule smart contracts
    """

    # TODO: Clear and Approvals

    @abimethod()
    def initalize(self, details: CertificateDetails, cert: Certificate) -> Root:
        self.set_details(details)
        self.set_certificate(cert)

        # Metrics
        self.requests = UInt64(0)
        self.issued = UInt64(0)
        self.revoked = UInt64(0)

        return self.get()

    @abimethod()
    def sign(self) -> bool:
        return True

    @abimethod()
    def revoke(self, cert_id: String) -> bool:
        return True

    @abimethod()
    def renew(self, cert_id: String) -> bool:
        return True

    @subroutine
    def get(self) -> Root:
        return Root(
            revocation_list=self.revocation_list,
            details=self.get_details(),
            cert=self.get_certificate(),
            metrics=self.get_metrics(),
        )
