stage("Build") {
    parallel (
        "Windows" : {
            node('windows') {
                checkout scm
                bat 'git submodule update --init'
                bat 'powershell.exe .\\Build.ps1'
                stash includes: 'dist/**', name: 'windows'
                archiveArtifacts 'dist/**'
            }
        },
        "macOS" : {
            node('mac') {
                checkout scm
                bat 'git submodule update --init'
                bat './build.mac.sh'
                stash includes: 'dist/**', name: 'mac'
                archiveArtifacts 'dist/**'
            }
        }
    )
}
