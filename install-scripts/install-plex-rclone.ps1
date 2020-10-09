param(
    #Path to folder to write docker-compose file.
    [string] $programfolder = 'C:\plex-rclone',
    [int] $plex_port = 32400,
    [int] $delay = 1
)

$LanInterface = Get-NetIPAddress -AddressFamily IPv4 | Where-Object -FilterScript { $_.ValidLifetime -Ne ([TimeSpan]::MaxValue) }
Write-Output ("Discovered Local IPAddress: " + $LanInterface[0].IPv4Address)


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
    image: artificiallyintelligent/plex-rclone:test
    container_name: plex
    devices:
      - "/dev/fuse:/dev/fuse"
    cap_add:
      - SYS_ADMIN
    environment:
      - PUID=99
      - PGID=100
      - VERSION=docker
      - UMASK_SET=022 #optional
      - PLEX_CLAIM=REPLACE_ME #optional
      - ADVERTISE_IP="http://' + $LanInterface[0].IPv4Address + ':' + $plex_port.ToString() + '"
      # - RCLONE_SERVE_PORT=13670
      - RCLONE_GUI=TRUE
      - "RCLONE_DRIVE_TEAM_DRIVE=0ALNBa0QBHhldUk9PVA"
      - "RCLONE_DRIVE_SCOPE=drive.readonly"
      - ''RCLONE_DRIVE_SERVICE_ACCOUNT_CREDENTIALS={"type": "service_account","project_id": "rclone-280007","private_key_id": "2fa244747e21efcecd31727203c0abbe1a6c10f9","private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC3EvvM8GbYejVR\nS0R2+qxdgcNOrc69fBiUOANKNtj/ry1tHm9DrtmctlcB/Va4QmQ000dPT7xB+zTH\nGIOUvsCJXJAntXmYDJyGWlMhRNcR/InvFJ0prWuwjKMxx6vijNpb5BRBXNEJVWxi\nl1CLdyur+IUlWIxV0jcsgl7OeTCpsA8Q5zua2GPamay7AUzSZs5/n4/azhbPRH2b\nMTvpzLEEIqVDFGJMQ5EOr0fiIb8Gq/6tYdMkdU15xREzQ2MUvDh/RsXhss5+J8UO\nU5BTNEFFoqTXBy+T8a+dipRGXrhIlFh5V1yB2uoShglv3OW/nyzsEA28D7+TIj2T\nGWNVgTARAgMBAAECggEAAWl+kraZ/Hp41c8wUICferso//7cNN7zq5UBBX4Fz3cQ\n8SIGdq2vFQPdCPFkzVgJwNSOXMC/MX0YC58XSLrt7kFOBVhjfzY9sNWahYur4wIh\nKDxu9+bUCVEUYypom389oe7Q7y4hmKJViy8immjJZ/KrSD32GyVbcpbw10PdCboE\nELfIa026HgAc6mhtMIuVDa1IKV5P+adBHlFpnIiivYbaJS03y0Y27AzMTdikUog4\nDrwQOQjb+J8Yvtvh0DicyHiWpoo3PblEbNVD3po5jU5HRqYyGr+C4/aGE9VoX63y\nSFPvy/p0vDZLHOXijwxmnp6z8chfnuWUQp7FDL26AQKBgQDuogJcBHLPgZw8Yd6Q\nXUyw2ROCkIDlAqynRr05EgBHxqGR0kxeG+VbJR58ST0+pcLXws1/qAgKgwtjRSQX\nIfDMcc1vXBTmLMzp5e5O8gCId0a+I0WehfFxRlvwFu70wWGbaMcWB5KJiAU9g28p\nIbgDUqHHrf8SuoBAtq7uT3gfUQKBgQDEZdrtuUQx/DJnOM3cH6GJIrSl5w34VjnB\nyGjnxrU60ddVxKom4h7OuFSap1pqAe8vCu38VKFrvbe4lnICt5R47J8BYHZDgXYg\nvbIhSdvHOU0sX3Mx39t1DEYreWH8NDwgcGu/z3zwB1LM1ugPtHWjIcAHhKlpm4G/\n/RC7qjtUwQKBgQDbXvXaT4CX/+d3nuTyQ8LXpIcJ9Pt5C89aa25SQ5kcYp5vJits\nLCrZcjMnQFDcAZgvrvYpD3hs6XETjiESXvI1j7yyTa0suCycLPK5gkE5MqVG77f1\ndd6yKmMkQIDlYczwCA9U0htE8VUX6nbLEiNOcq0kmnCtb+OtGgOQMmAUMQKBgQCe\nGjjR4rDpZFLXEb13FOefVBcE7yop3pAEVedNnoNKZJ7q5rTrNGEEnRNOpKZ+bCw2\nPKA035RK/aEmscX6NfsKFcIzA4pw8Yk89jit351Tledwby522fT7FvRuDvs4Ynx8\nyMOU192GBP8880xBSE7jEkpaQwt2fr9G5NxRlsrIgQKBgGl0F3HLylgimI3/WIvU\nQC/oaQAIOkJsZtZ34GWgUakuSDA2IATR3czQgTsV0yjZTzOo2agix3uYZ5QhUswq\nvhv/9WzhfACJc9BRedsblJusbwbX4UpXthswdTtA7AyuPqHALzhKn7xbpqCouPPs\nwOHyC5qCzJn+nE+HHJQ3TLrm\n-----END PRIVATE KEY-----\n","client_email": "plex-rclone-container@rclone-280007.iam.gserviceaccount.com",  "client_id": "106557646939466827684",  "auth_uri": "https://accounts.google.com/o/oauth2/auth",  "token_uri": "https://oauth2.googleapis.com/token",  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/plex-rclone-container%40rclone-280007.iam.gserviceaccount.com"}''
      - "RCLONE_CRYPT_PASSWORD=j3UvpVE7TxqAscDp7O-28-bzmKdgENxCMdqrwb8aQ9vzqLx7f4JIGtSMhzTjRNmHM_oHYqQoad61jr3m6TV9L3gceb_LBMFGX1X4I5IkrPxYQgE-pglSZRfkiGO2LUYsu3X7myid0-lMBGcjPdEIYBEzkyRFGB3q3woDnYdDWrQY7yzJuMMPwB_X5jwCPC-p2ad-YyyxhHggrDLhfbieePvotjTeGY9S9ue-uWzUSl6d19Kji7er-iUJag"
      - "RCLONE_CRYPT_PASSWORD2=JhaXkC7UOC_ecNAP2kNmHZ4rq1nmQ6XyGzh02v_Au8GpnJXEg_5KTONa8lXrezUVgLn9nrLrLrNjZ7OdeYXt1vmAKKHuUGBVrkyD_iz3YWre5AXknmTuyE0dCYNe2CbMrmqDYROV6DkvrCpdEAQ2620U1iZFJVWNjGasCtWh-Al3sw5poQ2cCdEYasV1Eq-6k4wOPUQBGGpTBEFU0USfaQCGoJ9GUZ6eWoqXg-1DcU-_Y9sNSyU4NRz8pA"
      - "RCLONE_CRYPT_DIRECTORY_NAME_ENCRYPTION=true"
      - "RCLONE_CRYPT_FILENAME_ENCRYPTION=standard"
      - "PLEX_LIBRARY_MASTER_PATH=/mnt/rclone/Storage/plex-library-v2.tar.gz"
      - ''PLEXDRIVE_CONFIG_JSON={"ClientID":"417005134584-olp2v0h5ffb396kdthin4shfj9vsg1fn.apps.googleusercontent.com","ClientSecret":"2D1QAHVtaez4BFqiGEd020fB"}''
      - ''PLEXDRIVE_TOKEN_JSON={"access_token":"ya29.a0AfH6SMA9vXOdWpzv3HQTcXer10tJaudGaoUsZULwyuTtWVkW95AVJ7GeNUiwM6B_IMclgbl9NSBcKe8QyrW_NQx1CTPFW8I51DTVazfGtIy5RKI57p8CZ6t0sUYGh_FS7IvIg9A_lC8dNyyffzrOqrgkFfHD6W1W3hE","token_type":"Bearer","refresh_token":"1//0gczToZ9i0dzGCgYIARAAGBASNwF-L9IrgTF92rq_uPzzCm7L-MDzqlxPDFcpJxqJkubs9XByKumsQ1tdwghWBAMQUj4Wj3IMM_k","expiry":"2020-06-25T19:36:54.398361227+10:00"}''
      - PLEXDRIVE=TRUE
      - FriendlyName=plex-rclone
      - allowedNetworks=192.168.0.0/16,172.16.0.0/12,10.0.0.0/8
      - LanNetworksBandwidth=192.168.0.0/16,172.16.0.0/12,10.0.0.0/8
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
    volumes:
      - plex_temp:/transcode
      - plex_config:/config
    ports:
      - "1900:1900/udp"
      - "3005:3005"
      - "5353:5353/udp"
      - "8384:8384"
      - "13668-13670:13668-13670"
      - "32410-32414:32410-32414/udp"
      - "32469:32469"
      - "' + $plex_port.ToString() + ':32400"
    restart: unless-stopped
  watchtower:
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


if( (test-url($plex_url )) -eq 200){
    Write-Error "Plex Media Server Port allready allocated, try running again with flag: -plex_port 12345"
    Exit 1
}

$quiet = mkdir -f  $programfolder

$dockercompose_filename = 'docker-compose.yaml'
$dockercompose_filepath = (Join-Path -Path $programfolder -ChildPath $dockercompose_filename)

Out-File -FilePath $dockercompose_filepath -InputObject $dockercompose
docker-compose.exe -f ($dockercompose_filepath) up -d

# We then get a response from the site.
while((test-url($plex_url )) -ne 200){
    Write-Output ("Plex library download and install not complete yet. Sleeping " + $delay.ToString() + " min then checking again.")
    sleep ($delay * 60)
}

Start $plex_url