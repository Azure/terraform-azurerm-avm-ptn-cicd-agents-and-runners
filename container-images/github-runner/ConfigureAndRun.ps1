$token = $env:GH_RUNNER_TOKEN
$url = $env:GH_RUNNER_URL
$runnerName = $env:GH_RUNNER_NAME
$runnerGroup = $env:GH_RUNNER_GROUP
$runnerMode = $env:GH_RUNNER_MODE

$hasRunnerGroup = ($null -ne $runnerGroup -and $runnerGroup -ne "")
$isEphemeral = $true

if($null -ne $runnerMode -and $runnerMode -ne "" -and $runnerMode.ToLower() -eq "persistent") {
    $isEphemeral = $false
}

# Get the runner registration token from the GitHub API if a PAT is supplied
$isPat = $false
if($token.StartsWith("ghp_") -or $token.StartsWith("github_pat_")) {
    $isPat = $true
}

if($isPat) {
    $githubUrlSplit = $url.Split("/", [System.StringSplitOptions]::RemoveEmptyEntries)
    $githubOrgRepoSegment = ""

    if($githubUrlSplit.Length -eq 3) {
        $githubOrgRepoSegment = $githubUrlSplit[-1]
    } else {
        $githubOrgRepoSegment = $githubUrlSplit[-2] + "/" + $githubUrlSplit[-1]
    }

    $tokenApiUrl = "https://api.github.com/repos/$($githubOrgRepoSegment)/actions/runners/registration-token"

    $headers = @{}
    $headers.Add("Authorization", "bearer $token")
    $headers.Add("Accept", "application/vnd.github.v3+json")

    $token = (Invoke-RestMethod -Uri $tokenApiUrl -Headers $headers -Method Post).token
}

# Register the runner
$env:RUNNER_ALLOW_RUNASROOT = "1"
if($hasRunnerGroup) {
    if($isEphemeral) {
        ./config.sh --unattended --replace --url $url --token $token --name $runnerName --runnergroup $runnerGroup --ephemeral
    } else {
        ./config.sh --unattended --replace --url $url --token $token --name $runnerName --runnergroup $runnerGroup
    }
} else {
    if($isEphemeral) {
        ./config.sh --unattended --replace --url $url --token $token --name $runnerName --ephemeral
    } else {
        ./config.sh --unattended --replace --url $url --token $token --name $runnerName
    }
}

./run.sh
