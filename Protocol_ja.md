# SimplePacket プロトコル仕様 (Version 1.0)

このドキュメントは、データフレームをエンコードおよびデコードするためのシンプルなプロトコルである SimplePacket プロトコルについて説明する。[English](Protocol.md)

## Packet

`Packet`はデータの単位である。以下の構造を持つ：

- **type**: 1バイト (UInt8)
- **length**: 2バイト (16ビット符号なし整数、リトルエンディアン)
- **payload**: Nバイト (データのペイロード)

### 構造

| フィールド | サイズ  | 説明                                        |
| ---------- | ------- | ------------------------------------------- |
| type       | 1バイト | パケットの種類を示す                        |
| length     | 2バイト | ペイロードの長さを示す (リトルエンディアン) |
| payload    | Nバイト | データのペイロード                          |

### EOF Packet

EOF (End of Frame) パケットはフレームの終わりを示す特別なパケットである。以下の構造を持つ：

- **type**: 0
- **length**: 0
- **payload**: 空

EOFパケットはフレームを終了するために使用される。

## Frame

`Frame`は複数の`Packet`から構成されるデータの単位である。フレームはEOFパケットで終了する必要がある。

### 構造

1つのフレームは以下のように構成される：

1. 1つ以上の`Packet`
2. EOF Packet (typeが0のパケット)

### デコード

フレームをデコードする際の手順は以下の通りである：

1. データの長さが3バイト未満の場合、`FrameDecoderError.invalidFrame`エラーをスローする。
2. データを1バイトずつ読み取り、`Packet`を生成する。
3. `Packet`のtypeが0の場合、フレームの終わりと見なす。
4. データの長さが3バイト未満の場合、`PacketDecoderError.invalidPacket`エラーをスローする。
5. `Packet`のlengthフィールドを読み取り、ペイロードの長さを取得する。
6. ペイロードを読み取る。
7. デコードが完了したら、`Packet`の配列を返す。

### エラー

- `FrameDecoderError.invalidFrame`: フレームが無効な場合にスローされる。
- `PacketDecoderError.invalidPacket`: パケットが無効な場合にスローされる。
- `PacketDecoderError.invalidPayload`: ペイロードが無効な場合にスローされる。

## エンコード

フレームをエンコードする際の手順は以下の通りである：

1. 各`Packet`のtype、length、およびpayloadを順にバイト列に変換する。
2. すべての`Packet`をバイト列に変換した後、EOF Packet (typeが0のパケット) を追加する。
3. バイト列を返す。

### エンコード例

1. `Packet`のtypeが1、lengthが3、payloadが"abc"の場合、バイト列は以下のようになる：
   - type: 0x01
   - length: 0x03 0x00 (リトルエンディアン)
   - payload: 0x61 0x62 0x63 ("abc"のASCIIコード)

2. EOF Packetを追加すると、最終的なバイト列は以下のようになる：
   - 0x01 0x03 0x00 0x61 0x62 0x63 0x00 0x00 0x00

このバイト列がエンコードされたフレームとなる。