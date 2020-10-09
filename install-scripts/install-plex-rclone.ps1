param(
    #Path to folder to write docker-compose file.
    [string] $programfolder = 'C:\plex-rclone',
    [int] $plex_port = 32400,
    [int] $delay = 1
)

$LanInterface = Get-NetIPAddress -AddressFamily IPv4 | Where-Object -FilterScript { $_.ValidLifetime -Ne ([TimeSpan]::MaxValue) }
$hostname = hostname
Write-Output ("Discovered Local IPAddress: " + $LanInterface[0].IPv4Address)

$host_subnet = "192.168.0.0/16,172.16.0.0/12,10.0.0.0/8"
$host_subnet = ([IPAddress] (([IPAddress] $LanInterface[0].IPv4Address).Address -band ([IPAddress] "255.255.255.0").Address)).ToString() + "/32"




function test-url($uri){
    $status = 400
    try {
        $HTTP_Request = [System.Net.WebRequest]::Create($uri)
        $HTTP_Response = $HTTP_Request.GetResponse()
        $status = [int]$HTTP_Response.StatusCode
    }catch{}
    return($status)
}

$dockercompose = ('
version: "2.1"
services:
  plex:
    image: artificiallyintelligent/plex-rclone
    container_name: plex-rclone
    devices:
      - "/dev/fuse:/dev/fuse"
    cap_add:
      - SYS_ADMIN
    environment:
      - PUID=99
      - PGID=100
      - VERSION=latest
      - UMASK_SET=022 #optional
      - PLEX_CLAIM=REPLACE_ME #optional
      # - RCLONE_SERVE_PORT=13670
      - RCLONE_GUI=TRUE
      - "RCLONE_CONFIG_ENCRYPTED=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"
      - "PLEX_LIBRARY_MASTER_PATH=/mnt/rclone/Storage/Backup/plex-rclone/plex-library.tar.gz"
      - PLEXDRIVE=TRUE
      - FriendlyName=' + $hostname + '-docker
      - ADVERTISE_IP="http://' + $LanInterface[0].IPv4Address + ':' + $plex_port.ToString() + '" # this should be the ip address of the host computer
      - allowedNetworks='+ $host_subnet + '
      - LanNetworksBandwidth='+ $host_subnet + '
      - TreatWanIpAsLocal=1
      - DlnaEnabled=1
      - autoEmptyTrash=0
      - ButlerEndHour=8
      - ButlerStartHour=5
      - ButlerTaskDeepMediaAnalysis=0
      - ButlerTaskUpgradeMediaAnalysis=0
      - ButlerTaskRefreshLibraries=1
      - GenerateChapterThumbBehavior=never
      - LoudnessAnalysisBehavior=never
      - ScheduledLibraryUpdateInterval=86400
      - ScheduledLibraryUpdatesEnabled=1
      - TranscoderTempDirectory=/transcode
      - RelayEnabled=0
      - OP=s0Qib5trYnlxujiTSIyCax2UhYQj3NHvJJazeg
      - CUSTOM_PLEX_PROFILES=chromecast
    volumes:
      - plex_temp:/transcode
      - plex_config:/config
    ports:
      - "3005:3005"
      - "8384:8384"
      - "13668-13670:13668-13670"
      - "32469:32469"
      - "' + $plex_port.ToString() + ':32400"
    restart: unless-stopped
  watchtower:
    container_name: watchtower
    image: containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --schedule "0 0 15 * * *" 
    restart: unless-stopped
volumes:
  plex_temp:
  plex_config:

')

# Check if plex is active yet.
$plex_url = 'http://localhost:' + $plex_port.ToString() + '/web/index.html'


#if( (test-url($plex_url )) -eq 200){
#    Write-Error "Plex Media Server Port allready allocated, try running again with flag: -plex_port 12345"
#    Exit 1
#}

$quiet = mkdir -f  $programfolder

$dockercompose_filename = 'docker-compose.yaml'
$dockercompose_filepath = (Join-Path -Path $programfolder -ChildPath $dockercompose_filename)

Out-File -FilePath $dockercompose_filepath -InputObject $dockercompose
Set-Location $programfolder
docker-compose.exe pull
docker-compose.exe -f ($dockercompose_filepath) up -d

$docker_auth = 'docker.exe exec -it plex-rclone authenticate'
Write-Output $docker_auth
cmd /c  $docker_auth

docker-compose.exe restart

# We then get a response from the site.
while((test-url($plex_url )) -ne 200){
    Write-Output ("Plex library download and install not complete yet. Sleeping " + $delay.ToString() + " min then checking again.")
    Start-Sleep ($delay * 60)
}

Start-Process $plex_url

