#
# SQL VM DSC
#

Configuration ExampleDSC
{

	Node "WebServer" {

        # Install necessary Windows Features / Services
		WindowsFeature InstallDotNet45 {
			Name = "Web-Asp-Net45"
			Ensure = "Present"
		}
		WindowsFeature IIS {
			Name = "Web-Server"
			Ensure = "Present"
		}
	}
}


