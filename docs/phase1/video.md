# Phase I prototype demonstration

[Download the video (MP4)](https://raw.githubusercontent.com/Mystic-commits/pipeline-hazard-unit/main/docs/media/prototype-demo.mp4) · [Repository video file](../media/prototype-demo.mp4)

**Duration:** 4 minutes 51 seconds, below the five-minute limit.  
**Format:** 1920 × 1080, 24 fps, H.264 video with AAC audio.  
**Narration:** Yug Johri, presenting on behalf of Team Snorlax.

The demonstration introduces all five members: Ishita Thakur, Aditya Verma, Yug Johri, Anshvardhan, and Swagato Bauri. The narrated walkthrough combines the report and code views, recorded verification output, and captured simulation measurements.

## Chapters

| Start | Topic | Project evidence shown |
|---|---|---|
| 0:00 | Introduction and team | Report title and all five member names |
| 0:26 | Five-stage pipeline and RAW dependency | Block diagram; ADD/SUB dependency example |
| 1:06 | Operand forwarding | Forwarding RTL, priority, zero register and selector table |
| 1:52 | Load-use hazard control | Hazard detection, PC/decode hold and EX bubble logic |
| 2:46 | Verification | Successful recorded `make verify` execution and PASS output |
| 3:38 | Performance results | Ten-instruction comparison: 15 versus 26 cycles |
| 3:58 | Waveform cases | Load-use samples at 100 ns and 120 ns |
| 4:14 | Handling disabled | Deliberate stale-register failure versus correct protected modes |
| 4:24 | Conclusion | Supported instruction subset and public repository |

## Playback

Use the direct download link above if GitHub's file page does not display an embedded player. The MP4 can be opened in a browser or a standard video player after downloading. The public video does not require a repository invitation.

The block diagram and numerical tables are explained in the [IEEE report](ieee-report.pdf). The implementation and measurement assumptions are documented in the [architecture](../architecture.md) and [verification guide](../verification.md).
