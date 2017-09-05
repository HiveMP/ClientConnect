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
                sh 'git submodule update --init'
                sh './build.mac.sh'
                stash includes: 'dist/**', name: 'mac'
                archiveArtifacts 'dist/**'
            }
        },
        "Linux" : {
            node('linux') {
                checkout scm
                sh 'git submodule update --init'
                sh './build.linux.sh'
                stash includes: 'dist/**', name: 'linux'
                archiveArtifacts 'dist/**'
            }
        }
    )
}
