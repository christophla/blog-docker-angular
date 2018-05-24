<#
.SYNOPSIS
	Orchestrates docker images.
.PARAMETER Clean
	Removes the image and kills all containers based on the image.
.PARAMETER Compose
	Builds and runs a Docker image.
.EXAMPLE
	C:\PS> .\project-tasks.ps1 -Compose 
#>

[CmdletBinding(PositionalBinding = $false)]
Param(
    [switch]$Clean,
    [switch]$Compose,
    [ValidateNotNullOrEmpty()]
    [String]$Environment = "development"
)


# ###############################################
# Settings
#
$Environment = $Environment.ToLowerInvariant()


# ###############################################
# Kills all running containers of an image
#
Function Clean () {

   
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Cleaning projects and docker images           " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"

    $composeFileName = "docker-compose.yml"
    If ($Environment -ne "development") {
        $composeFileName = "docker-compose.$Environment.yml"
    }

    If (Test-Path $composeFileName) {
        docker-compose -f "$composeFileName" -p $ProjectName down --rmi all

        $danglingImages = $(docker images -q --filter 'dangling=true')
        If (-not [String]::IsNullOrWhiteSpace($danglingImages)) {
            docker rmi -f $danglingImages
        }
        Write-Host "Removed docker images" -ForegroundColor "Yellow"
    }
    else {
        Write-Error -Message "Environment '$Environment' is not a valid parameter. File '$composeFileName' does not exist." -Category InvalidArgument
    }
}


# ###############################################
# Runs docker-compose.
#
Function Compose () {

    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Composing docker images                       " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"

    # Fix for binding sock in docker 18.x on windows
    # https://github.com/docker/for-win/issues/1829
    $Env:COMPOSE_CONVERT_WINDOWS_PATHS=1

    $composeFileName = "docker-compose.yml"
    If ($Environment -ne "development") {
        $composeFileName = "docker-compose.$Environment.yml"
    }

    If (Test-Path $composeFileName) {

        Write-Host "Building the image..." -ForegroundColor "Yellow"
        docker-compose -f "$composeFileName" build

        Write-Host "Creating the container..." -ForegroundColor "Yellow"
        docker-compose -f $composeFileName kill
        docker-compose -f $composeFileName up -d
    }
    else {
        Write-Error -Message "Environment '$Environment' is not a valid parameter. File '$composeFileName' does not exist." -Category InvalidArgument
    }
}


# #############################################################################
# Setup the project
#
Function Setup () {

    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"
    Write-Host "+ Setting up project                            " -ForegroundColor "Green"
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor "Green"

    Write-Host "Done" -ForegroundColor "Yellow"

}


# #############################################################################
# Switch arguments
#

If ($Clean) {
    Clean
}
elseIf ($Compose) {
    $env:ENABLE_POLLING = "enabled"
    Compose
}
elseIf ($Setup) {
    Setup
}


# #############################################################################
