## Clean Up

To remove all resources created by this example:

```bash
terraform destroy
```

**Note**: This will remove:
- All Azure resources (Container Apps, UAMI, networking, etc.)
- Azure DevOps project and all associated resources
- Service connections and agent pools

## Next Steps

1. **Customize for Production**: Review security settings, network policies, and RBAC permissions
2. **Scale Configuration**: Adjust container scaling rules based on your workload
3. **Multi-Environment**: Use this pattern for dev/staging/prod environments
4. **Custom Agents**: Build custom container images with your required tools
5. **Monitoring**: Set up alerts and dashboards for agent performance

## Support

This example follows Azure Verified Modules (AVM) standards. For issues:
- **Module Issues**: [AVM Repository Issues](https://github.com/Azure/terraform-azurerm-avm-ptn-cicd-agents-and-runners/issues)
- **Azure DevOps Provider**: [Provider Documentation](https://registry.terraform.io/providers/microsoft/azuredevops/latest)
- **Azure Documentation**: [Container Apps](https://docs.microsoft.com/azure/container-apps/)

Remember to follow the [AVM Contributing Guidelines](https://azure.github.io/Azure-Verified-Modules/contributing/) when submitting improvements.
