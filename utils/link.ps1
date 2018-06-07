Set-Location -Path "$PSScriptRoot\.."

If(-Not (Test-Path -Path "libs")){
	New-Item -ItemType Directory -Path libs
}

If(-Not (Test-Path -Path "libs\LibStub")){
	New-Item -ItemType SymbolicLink -Path "libs" -Name LibStub -Value ..\LibStub
} ElseIf(-Not (((Get-Item -Path "libs\LibStub").Attributes.ToString()) -Match "ReparsePoint")){
	Remove-Item -Path "libs\LibStub"
	New-Item -ItemType SymbolicLink -Path "libs" -Name LibStub -Value ..\LibStub
}

If(-Not (Test-Path -Path "libs\LibProcessable")){
	New-Item -ItemType SymbolicLink -Path "libs" -Name LibProcessable -Value ..\LibProcessable
} ElseIf(-Not (((Get-Item -Path "libs\LibProcessable").Attributes.ToString()) -Match "ReparsePoint")){
	Remove-Item -Path "libs\LibProcessable"
	New-Item -ItemType SymbolicLink -Path "libs" -Name LibProcessable -Value ..\LibProcessable
}

If(-Not (Test-Path -Path "libs\Wasabi")){
	New-Item -ItemType SymbolicLink -Path "libs" -Name Wasabi -Value ..\Wasabi
} ElseIf(-Not (((Get-Item -Path "libs\Wasabi").Attributes.ToString()) -Match "ReparsePoint")){
	Remove-Item -Path "libs\Wasabi"
	New-Item -ItemType SymbolicLink -Path "libs" -Name Wasabi -Value ..\Wasabi
}
