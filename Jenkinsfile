stage("Windows 32-bit / 64-bit") {
    node('windows') {
        checkout scm
        powershell '.\Build.ps1'
        stash includes: 'dist/**', name: 'windows'
    }
}