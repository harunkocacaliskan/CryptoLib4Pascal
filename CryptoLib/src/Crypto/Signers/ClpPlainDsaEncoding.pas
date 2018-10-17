{ *********************************************************************************** }
{ *                              CryptoLib Library                                  * }
{ *                Copyright (c) 2018 - 20XX Ugochukwu Mmaduekwe                    * }
{ *                 Github Repository <https://github.com/Xor-el>                   * }

{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }

{ *                              Acknowledgements:                                  * }
{ *                                                                                 * }
{ *      Thanks to Sphere 10 Software (http://www.sphere10.com/) for sponsoring     * }
{ *                           development of this library                           * }

{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit ClpPlainDsaEncoding;

{$I ..\..\Include\CryptoLib.inc}

interface

uses
  Math,
  ClpIDerInteger,
  ClpBigInteger,
  ClpIDsaEncoding,
  ClpIPlainDsaEncoding,
  ClpBigIntegers,
  ClpArrayUtils,
  ClpCryptoLibTypes;

resourcestring
  SInvalidEncodingLength = 'Encoding has incorrect length, "%s"';
  SValueOutOfRange = 'Value out of range, "%s"';

type
  TPlainDsaEncoding = class(TInterfacedObject, IDsaEncoding, IPlainDsaEncoding)

  strict private
    class var

      FInstance: IPlainDsaEncoding;

    class function GetInstance: IPlainDsaEncoding; static; inline;

    class constructor PlainDsaEncoding();

  strict protected

    function CheckValue(const n, x: TBigInteger): TBigInteger; virtual;
    function DecodeValue(const n: TBigInteger; const buf: TCryptoLibByteArray;
      off, len: Int32): TBigInteger; virtual;
    procedure EncodeValue(const n, x: TBigInteger;
      const buf: TCryptoLibByteArray; off, len: Int32); virtual;

  public

    function Decode(const n: TBigInteger; const encoding: TCryptoLibByteArray)
      : TCryptoLibGenericArray<TBigInteger>; virtual;

    function Encode(const n, r, s: TBigInteger): TCryptoLibByteArray; virtual;

    class property Instance: IPlainDsaEncoding read GetInstance;

  end;

implementation

{ TPlainDsaEncoding }

function TPlainDsaEncoding.CheckValue(const n, x: TBigInteger): TBigInteger;
begin
  if ((x.SignValue < 0) or ((x.CompareTo(n) >= 0))) then
  begin
    raise EArgumentCryptoLibException.CreateResFmt(@SValueOutOfRange, ['x']);
  end;
  result := x;
end;

function TPlainDsaEncoding.Decode(const n: TBigInteger;
  const encoding: TCryptoLibByteArray): TCryptoLibGenericArray<TBigInteger>;
var
  valueLength: Int32;
begin
  valueLength := TBigIntegers.GetUnsignedByteLength(n);
  if (System.Length(encoding) <> (valueLength * 2)) then
  begin
    raise EArgumentCryptoLibException.CreateResFmt(@SInvalidEncodingLength,
      ['encoding']);
  end;
  result := TCryptoLibGenericArray<TBigInteger>.Create
    (DecodeValue(n, encoding, 0, valueLength), DecodeValue(n, encoding,
    valueLength, valueLength));
end;

function TPlainDsaEncoding.DecodeValue(const n: TBigInteger;
  const buf: TCryptoLibByteArray; off, len: Int32): TBigInteger;
begin
  result := CheckValue(n, TBigInteger.Create(1, buf, off, len));
end;

function TPlainDsaEncoding.Encode(const n, r, s: TBigInteger)
  : TCryptoLibByteArray;
var
  valueLength: Int32;
begin
  valueLength := TBigIntegers.GetUnsignedByteLength(n);
  System.SetLength(result, valueLength * 2);
  EncodeValue(n, r, result, 0, valueLength);
  EncodeValue(n, s, result, valueLength, valueLength);
end;

procedure TPlainDsaEncoding.EncodeValue(const n, x: TBigInteger;
  const buf: TCryptoLibByteArray; off, len: Int32);
var
  bs: TCryptoLibByteArray;
  bsOff, bsLen, pos: Int32;
begin
  bs := CheckValue(n, x).ToByteArrayUnsigned();
  bsOff := Max(0, System.Length(bs) - len);
  bsLen := System.Length(bs) - bsOff;
  pos := len - bsLen;
  TArrayUtils.Fill(buf, off, off + pos, Byte(0));
  System.Move(bs[bsOff], buf[off + pos], bsLen * System.SizeOf(Byte));
end;

class function TPlainDsaEncoding.GetInstance: IPlainDsaEncoding;
begin
  result := FInstance;
end;

class constructor TPlainDsaEncoding.PlainDsaEncoding;
begin
  FInstance := TPlainDsaEncoding.Create();
end;

end.
