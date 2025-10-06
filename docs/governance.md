# Governance and Compliance Guide for SMBC Financial Platform
This document outlines the governance framework for the Azure-based financial services platform. It ensures alignment with regulatory standards (e.g., PCI DSS 3.2.1, SOC 2 Type II, GDPR for EMEA/APAC operations) and Azure Well-Architected Framework pillars (Security, Reliability, Compliance). All resources are governed via Terraform IaC for auditability, with Azure Policy for enforcement.
## Key Principles
- **Least Privilege**: RBAC and Azure AD roles limit access (e.g., Security team owns Key Vault; DevOps reviews APIM policies).
- **Auditability**: All changes via CI/CD; logs retained 365 days in Azure Monitor.
- **Risk Mitigation**: Zero-trust model with TLS 1.3, OAuth/SAML validation, and WAF.
- **Repeatability**: Blueprints for dev/staging/prod environments.
## Compliance Mappings
| Standard | Requirement | Implementation | Azure Service |
|----------|-------------|----------------|---------------|
| **PCI DSS 3.2.1** | Encrypt cardholder data at rest/transit | Customer-managed keys in Cosmos DB/Key Vault; TLS enforcement | Azure Policy (Deny unencrypted storage) |
| **SOC 2 Type II** | Access controls and monitoring | RBAC + Azure Sentinel SIEM; anomaly detection | Azure Defender for Cloud |
| **GDPR** | Data residency and consent | Multi-region Cosmos DB (e.g., East US for Americas, Japan East for APAC); audit logs | Azure Policy (Restrict cross-region data flows) |
| **ISO 27001** | Incident response | Automated alerts via Logic Apps; 24-hour escalation | Azure Monitor + Sentinel playbooks |
## Azure Policies in Use
Deployed via `terraform/modules/policies/`:
- **Encryption Enforcement**: Deny creation of unencrypted storage accounts (Policy ID: `932d736c-0733-44f7-8f4a-8ec11b5a4ac0`).
- **TLS Minimum**: Audit non-TLS 1.2+ endpoints (Policy ID: `061f9a79-0a52-4c9f-9e4e-93e0e7a637a9`).
- **Custom Policies**: Rate limiting on APIM; IP whitelisting for AKS.
Apply via: `terraform apply` → Review assignments in Azure Portal > Policy > Assignments.
## Governance Processes
1. **Policy Reviews**: Quarterly governance committee (Security + DevOps); use Azure Blueprints for template validation.
2. **Architecture Decisions**: Influence via PR reviews—require approval from at least one Security engineer. Use Terraform plan outputs for impact analysis.
3. **Incident Response**:
   - **Detection**: Azure Sentinel rules for threats (e.g., anomalous API calls).
   - **Response**: Triage in <1 hour; rollback via `terraform destroy` for infra incidents.
   - **Post-Mortem**: Document in GitHub Issues; update IaC modules.
4. **Cross-Functional Collaboration**: Weekly syncs with Infrastructure/Application teams; share dashboards via Azure Monitor.
## Security Standards Implementation
- **Authentication**: OAuth 2.0/OpenID Connect via Azure AD (app registration required); SAML for federation (e.g., with Okta).
- **API/Web Services**: APIM policies for JWT validation, rate limiting (100 calls/min), and WAF (OWASP ruleset).
- **Secrets Management**: All creds in Key Vault; CSI driver for AKS pods.
- **Vulnerability Scanning**: Checkov in CI/CD; Microsoft Defender scans for images.
## Mentoring and Documentation
- **Onboarding**: New engineers review this doc + run `terraform plan` on a fork.
- **Updates**: Version this MD with repo tags; contribute via PRs.
For questions, reference [Azure Compliance Docs](https://learn.microsoft.com/en-us/azure/compliance/) or open an Issue.
*Last Updated: October 05, 2025*