# Throw-2-Discord

악성코드 분석 PC에서 캡처한 스크린샷을 **Discord Webhook**으로 보내, 보고서 PC에서 받아 쓰는 도구입니다.
분석 PC와 보고서 PC 사이에 파일 공유·USB를 연결하지 않아도 됩니다.

## 요구 사항

- Windows (PowerShell 5.1+, `curl.exe` 기본 포함)
- 이미지를 받을 Discord 채널의 Webhook URL

## 설치 (최초 1회)

1. `send_clipboard.cmd`, `send_clipboard_image.ps1`을 분석 PC의 같은 폴더에 둡니다.
2. `send_clipboard_image.ps1` 상단의 Webhook URL을 실제 값으로 바꿉니다.
   ```powershell
   $WebhookUrl = "https://discord.com/api/webhooks/XXXXX" # Fix Here!
   ```
3. `send_clipboard.cmd`를 한 번 실행합니다. URL이 사용자 환경 변수 `DISCORD_WEBHOOK_URL`에 등록됩니다.
4. 등록 후에는 스크립트의 URL을 `""`로 되돌려 파일에 남지 않게 합니다.

> Webhook URL은 문서나 저장소에 절대 커밋하지 마세요.

## 사용법

1. `Win + Shift + S`로 화면을 캡처합니다(클립보드에 이미지 저장).
2. `send_clipboard.cmd`를 실행합니다.
3. Discord 채널에 `YYYYMMDD_HHMMSS.png` 이름으로 업로드됩니다.

성공하면 2초 뒤 창이 닫히고, 실패하면 오류 메시지를 보여준 채 멈춥니다.

### 옵션 (PowerShell에서 직접 실행)

```powershell
powershell -STA -ExecutionPolicy Bypass -File .\send_clipboard_image.ps1 `
  -Session "20261020_211500_a1b2c3d4" -Note "C2: hxxp://evil[.]com" -Keep
```

| 옵션 | 설명 |
|------|------|
| `-Session` | 파일명 앞에 붙일 세션 ID (`YYYYMMDD_HHMMSS_<sha256 앞 8자리>`) |
| `-Note` | 이미지와 함께 보낼 메모. IOC는 반드시 defang 처리 (`hxxp`, `[.]`) |
| `-Keep` | 전송 후 임시 파일(`%TEMP%\report_send\`)을 삭제하지 않음 |

## 동작 / 제한

- 클립보드 이미지를 PNG로 재인코딩해 전송하므로 원본 파일이 아닌 픽셀만 넘어갑니다.
- 8MB 초과 이미지는 전송하지 않습니다.
- 클립보드 접근을 위해 STA 모드가 필요합니다(`.cmd`가 자동 처리).

## Webhook URL 변경·삭제

```powershell
[Environment]::SetEnvironmentVariable("DISCORD_WEBHOOK_URL", $null, "User")
```
삭제 후 설치 2~4단계를 다시 진행합니다.

## License

Apache License 2.0
