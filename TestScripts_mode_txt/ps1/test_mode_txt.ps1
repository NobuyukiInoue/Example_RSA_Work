param($keyfile1, $keyfile2, $file1, $file2, $file3, $code, $mode)

Write-Host "args ="$MyInvocation.MyCommand.Name $keyfile1 $keyfile2 $file1 $file2 $file3 $code $mode

##--------------------------------------------------------##
## �����`�F�b�N
##--------------------------------------------------------##

if (-Not($keyfile1) -Or -Not($keyfile2) -Or -Not($file1) -Or -Not($file2) -Or -Not($file3)) {
    Write-Host $keyfile1 $keyfile2 $file1 $file2 $file3
    Write-Host "Usage :"$MyInvocation.MyCommand.Name" public_key private_key org_file encrypted_file decrypted_file [mode]"
    exit
}

if (-Not($code)) {
    $code = "utf8"
}


if (-Not($mode)) {
    $mode = $TRUE
}
else {
    if ($mode -match "TRUE" -Or $mode -match "True" -Or $mode -match "true") {
        $mode = $TRUE
    }
    else {
        $mode = $FALSE
    }
}


##--------------------------------------------------------##
## ���ؑΏۃv���O�����̎w��
##--------------------------------------------------------##

$cmd_rsa_main = "../../rsa_main_mode_txt.py"
$cmd_filehash = "../../print_FileHash.py"


##--------------------------------------------------------##
## �Ώۃt�@�C���̎��O�폜
##--------------------------------------------------------##

if (Test-Path $keyfile1) {
    Remove-Item $keyfile1
}

if (Test-Path $keyfile2) {
    Remove-Item $keyfile2
}

if (Test-Path $file2) {
    Remove-Item $file2
}

if (Test-Path $file3) {
    Remove-Item $file3
}


##--------------------------------------------------------##
## ���J���^�閧���t�@�C���̐���
##--------------------------------------------------------##

$keyfiles = $keyfile1 + "`n" + $keyfile2 + "`n"

Write-Host "Execute: python"$cmd_rsa_main" create_key"
$keyfiles | python $cmd_rsa_main create_key > $NULL


##--------------------------------------------------------##
## �Í�������
##--------------------------------------------------------##

if ($mode) {
    ## ���J���ňÍ���
    Write-Host "Execute: python $cmd_rsa_main encrypt $file1 $keyfile1 $code"
    python $cmd_rsa_main encrypt $file1 $keyfile1 $code > $file2".unicode"
}
else {
    ## �閧���ňÍ���
    Write-Host "Execute: python $cmd_rsa_main encrypt $file1 $keyfile2 $code"
    python $cmd_rsa_main encrypt $file1 $keyfile2 $code > $file2".unicode"
}


get-content -Encoding Unicode $file2".unicode" | Set-Content $file2 -Encoding OEM
Remove-Item $file2".unicode"


##--------------------------------------------------------##
## ��������
##--------------------------------------------------------##

if ($mode) {
    ## �閧���ŕ���
    Write-Host "Execute: python $cmd_rsa_main decrypt $file2 $keyfile2 $code"
    python $cmd_rsa_main decrypt $file2 $keyfile2 $code > $file3".unicode"
}
else {
    ## ���J���ŕ���
    Write-Host "Execute: python $cmd_rsa_main decrypt $file2 $keyfile1 $code"
    python $cmd_rsa_main decrypt $file2 $keyfile1 $code > $file3".unicode"
}

get-content -Encoding Unicode $file3".unicode" | Set-Content $file3 -Encoding OEM
Remove-Item $file3".unicode"



##--------------------------------------------------------##
## ���t�@�C���̓��e��\��
##--------------------------------------------------------##

$key1 = Get-Content $keyfile1
$key2 = Get-Content $keyfile2
Write-Host $keyfile1.PadRight(20)":"$key1 -ForegroundColor Yellow
Write-Host $keyfile2.PadRight(20)":"$key2 -ForegroundColor Yellow


##--------------------------------------------------------##
## �Í����O�t�@�C���ƕ�����t�@�C�����o�͂���
##--------------------------------------------------------##

Write-Host "###### �Í����O:"$file1" ######" -ForegroundColor Cyan
Get-Content $file1
Write-Host "###### ������  :"$file3" ######" -ForegroundColor Cyan
Get-Content $file3
Write-Host "####################" -ForegroundColor Cyan
