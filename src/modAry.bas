Attribute VB_Name = "modAry"
Option Base 0
Option Explicit

Function lenAry(ary As Variant, Optional dm = 1) As Long
    lenAry = UBound(ary, dm) - LBound(ary, dm) + 1
End Function

Function getAryAt(ary As Variant, pos As Long, Optional base As Long = 1)
    Dim idx As Long
    Dim ret As Variant
    If pos < 0 Then
        idx = UBound(ary) + pos + 1
    Else
        idx = LBound(ary) + pos - base
    End If
    Assign getAryAt, ary(idx)
End Function

Sub setAryAt(ByRef ary As Variant, pos As Long, vl As Variant, Optional base As Long = 1)
    Dim idx As Long
    If pos < 0 Then
        idx = UBound(ary) + pos + 1
    Else
        idx = LBound(ary) + pos - base
    End If
    Assign ary(idx), vl
End Sub

Function getMAryAt(ary As Variant, pos As Variant, Optional base As Long = 1)
    Dim lNum As Long
    Dim lsp, bs, idx1, idx2, ret
    lsp = getAryShape(ary, "L")
    lNum = lenAry(lsp)
    bs = mkSameAry(base, lNum)
    idx1 = calcAry(pos, bs, "-")
    idx2 = calcAry(idx1, lsp, "+")
    ret = getElm(ary, idx2)
    getMAryAt = ret
End Function

Sub setMAryAt(ByRef ary As Variant, pos As Variant, vl As Variant, Optional base As Long = 1)
    Dim num As Long
    Dim lsp, bs, idx1, idx2
    lsp = getAryShape(ary, "L")
    lNum = lenAry(lsp)
    bs = mkSameAry(base, lNum)
    idx1 = calcAry(pos, bs, "-")
    idx2 = calcAry(idx1, lsp, "+")
    Call setElm(vl, ary, idx2)
End Sub

Public Function dimAry(ByVal ary As Variant) As Long
    On Error GoTo Catch
    Dim ret As Long
    ret = 0
    Do
        ret = ret + 1
        Dim tmp As Long
        tmp = UBound(ary, ret)
    Loop
Catch:
    dimAry = ret - 1
End Function

Function getAryShape(ary, Optional typ = "N")
    Dim i As Long, num As Long
    Dim tmp
    num = dimAry(ary)
    ReDim ret(0 To num - 1)
    For i = 1 To num
        Select Case UCase(typ)
            Case "N"
                tmp = lenAry(ary, i)
            Case "L"
                tmp = LBound(ary, i)
            Case "U"
                tmp = UBound(ary, i)
            Case Else
        End Select
        Call setAryAt(ret, i, tmp)
    Next i
    getAryShape = ret
End Function

Function getAryNum(ary) As Long
    Dim ret As Long
    Dim sp, elm
    sp = getAryShape(ary)
    'ret = reduceA("calc", sp, "*")
    ret = 1
    For Each elm In sp
        ret = ret * elm
    Next elm
    getAryNum = ret
End Function

Function conArys(ParamArray argArys())
    Dim num As Long, i As Long
    Dim arys, ret, elm, ary
    arys = argArys
    num = 0
    For Each ary In arys
        If IsArray(ary) Then
            num = num + getAryNum(ary)
        Else
            num = num + 1
        End If
    Next ary
    ReDim ret(0 To num - 1)
    i = 0
    For Each ary In arys
        If IsArray(ary) Then
            For Each elm In ary
                ret(i) = elm
                i = i + 1
            Next elm
        Else
            ret(i) = ary
            i = i + 1
        End If
    Next ary
    conArys = ret
End Function

Function mkSameAry(vl, lNum As Long)
    Dim i As Long
    ReDim ret(0 To lNum - 1)
    For i = 0 To lNum - 1
        ret(i) = vl
    Next i
    mkSameAry = ret
End Function

Function mkSeq(lNum As Long, Optional first = 1, Optional step = 1)
    ReDim ret(0 To lNum - 1)
    Dim i As Long
    For i = 0 To lNum - 1
        ret(i) = first + step * i
    Next i
    mkSeq = ret
End Function

Function dropAry(ary, num As Long)
    Dim lNum As Long, sz As Long, i As Long, lb As Long, ub As Long
    Dim ret
    lNum = lenAry(ary)
    sz = lNum - Abs(num)
    If sz < 0 Then
        Call Err.Raise(1001, "dropAry", "num is larger than array length")
    ElseIf sz = 0 Then
        ret = Array()
    ElseIf num > 0 Then
        ReDim ret(0 To sz - 1)
        lb = LBound(ary)
        For i = 0 To sz - 1
            ret(i) = getAryAt(ary, i + num, 0)
        Next i
    Else
        ReDim ret(0 To sz - 1)
        ub = UBound(ary)
        For i = 0 To sz - 1
            ret(i) = getAryAt(ary, i, 0)
        Next i
    End If
    dropAry = ret
End Function

Function takeAry(ary, num As Long)
    Dim lNum As Long, sz As Long, i As Long, lb As Long
    Dim ret
    lNum = lenAry(ary)
    sz = Abs(num)
    If sz < 0 Then
        Call Err.Raise(1001, "takeAry", "num is larger than array length")
    End If
    If num > 0 Then
        ReDim ret(0 To sz - 1)
        lb = LBound(ary)
        For i = 0 To sz - 1
            ret(i) = getAryAt(ary, i, 0)
        Next i
    ElseIf num < 0 Then
        ReDim ret(0 To sz - 1)
        ' ub = UBound(ary)
        For i = 0 To sz - 1
            ret(i) = getAryAt(ary, lNum - sz + i, 0)
        Next i
    Else
        ret = Array()
    End If
    takeAry = ret
End Function

Function revAry(ary)
    Dim lNum As Long, i As Long, lb As Long
    lNum = lenAry(ary)
    ReDim ret(0 To lNum - 1)
    lb = LBound(ary)
    For i = 0 To lNum - 1
        ret(i) = getAryAt(ary, lNum - i - 1, 0)
    Next i
    revAry = ret
End Function

Function zip(ParamArray argArys())
    Dim arys, ret
    arys = argArys
    ret = zipAry(arys)
    zip = ret
End Function

Function zipAry(arys)
    Dim rNum As Long, cNum As Long, lb As Long, c As Long, r As Long
    Dim ret, v
    rNum = lenAry(arys)
    cNum = lenAry(arys(LBound(arys)))
    ReDim ret(0 To cNum - 1)
    lb = LBound(arys)
    For c = 0 To cNum - 1
        ReDim v(0 To rNum - 1)
        For r = 0 To rNum - 1
            v(r) = getAryAt(arys(lb + r), c, 0)
        Next r
        ret(c) = v
    Next c
    zipAry = ret
End Function

Function prmAry(ParamArray argAry())
    Dim ret
    'flatten last elm
    Dim ary, ary1, ary2
    ary = argAry
    ary1 = dropAry(ary, -1)
    ary2 = getAryAt(ary, -1)
    ret = conArys(ary1, ary2)
    prmAry = ret
End Function

Function inAry(ary As Variant, elm As Variant) As Boolean
    Dim ret As Boolean
    ret = False
    For Each x In ary
        If x = elm Then
            ret = True
            Exit For
        End If
    Next x
    inAry = ret
End Function

Function mkIndex(num As Long, shape, Optional lshape = Empty)
    Dim lNum As Long, i As Long, p As Long, r As Long
    lNum = lenAry(shape)
    ReDim ret(0 To lNum - 1)
    r = num
    For i = n To 1 Step -1
        p = getAryAt(shape, i)
        Call setAryAt(ret, i, r Mod p)
        r = r \ p
    Next i
    If Not IsEmpty(lshape) Then
        For i = 1 To n
            Call setAryAt(ret, i, getAryAt(ret, i) + getAryAt(lshape, i))
        Next i
    End If
    mkIndex = ret
End Function

Function getElm(ByRef ary, idx)
    Dim ret
    Dim lb As Long
    lb = LBound(idx)
    Select Case lenAry(idx)
        Case 1: Assign ret, ary(idx(lb))
        Case 2: Assign ret, ary(idx(lb), idx(lb + 1))
        Case 3: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2))
        Case 4: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3))
        Case 5: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4))
        Case 6: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5))
        Case 7: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6))
        Case 8: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7))
        Case 9: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8))
        Case 10: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9))
        Case 11: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10))
        Case 12: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11))
        Case 13: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12))
        Case 14: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13))
        Case 15: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14))
        Case 16: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15))
        Case 17: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16))
        Case 18: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17))
        Case 19: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18))
        Case 20: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19))
        Case 21: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20))
        Case 22: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21))
        Case 23: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22))
        Case 24: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23))
        Case 25: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24))
        Case 26: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25))
        Case 27: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26))
        Case 28: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27))
        Case 29: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28))
        Case 30: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29))
        Case 31: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30))
        Case 32: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31))
        Case 33: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32))
        Case 34: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33))
        Case 35: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34))
        Case 36: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35))
        Case 37: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36))
        Case 38: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37))
        Case 39: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38))
        Case 40: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39))
        Case 41: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40))
        Case 42: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41))
        Case 43: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42))
        Case 44: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43))
        Case 45: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44))
        Case 46: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45))
        Case 47: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46))
        Case 48: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47))
        Case 49: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48))
        Case 50: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49))
        Case 51: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50))
        Case 52: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51))
        Case 53: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52))
        Case 54: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53))
        Case 55: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53), idx(lb + 54))
        Case 56: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53), idx(lb + 54), idx(lb + 55))
        Case 57: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53), idx(lb + 54), idx(lb + 55), idx(lb + 56))
        Case 58: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53), idx(lb + 54), idx(lb + 55), idx(lb + 56), idx(lb + 57))
        Case 59: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53), idx(lb + 54), idx(lb + 55), idx(lb + 56), idx(lb + 57), idx(lb + 58))
        Case 60: Assign ret, ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53), idx(lb + 54), idx(lb + 55), idx(lb + 56), idx(lb + 57), idx(lb + 58), idx(lb + 59))
        Case Else:
    End Select
    Assign getElm, ret
End Function

Sub setElm(vl, ary, idx)
    Dim lb As Long
    lb = LBound(idx)
    Select Case lenAry(idx)
        Case 1: Assign ary(idx(lb)), vl
        Case 2: Assign ary(idx(lb), idx(lb + 1)), vl
        Case 3: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2)), vl
        Case 4: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3)), vl
        Case 5: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4)), vl
        Case 6: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5)), vl
        Case 7: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6)), vl
        Case 8: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7)), vl
        Case 9: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8)), vl
        Case 10: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9)), vl
        Case 11: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10)), vl
        Case 12: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11)), vl
        Case 13: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12)), vl
        Case 14: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13)), vl
        Case 15: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14)), vl
        Case 16: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15)), vl
        Case 17: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16)), vl
        Case 18: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17)), vl
        Case 19: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18)), vl
        Case 20: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19)), vl
        Case 21: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20)), vl
        Case 22: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21)), vl
        Case 23: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22)), vl
        Case 24: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23)), vl
        Case 25: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24)), vl
        Case 26: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25)), vl
        Case 27: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26)), vl
        Case 28: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27)), vl
        Case 29: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28)), vl
        Case 30: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29)), vl
        Case 31: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30)), vl
        Case 32: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31)), vl
        Case 33: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32)), vl
        Case 34: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33)), vl
        Case 35: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34)), vl
        Case 36: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35)), vl
        Case 37: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36)), vl
        Case 38: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37)), vl
        Case 39: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38)), vl
        Case 40: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39)), vl
        Case 41: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40)), vl
        Case 42: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41)), vl
        Case 43: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42)), vl
        Case 44: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43)), vl
        Case 45: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44)), vl
        Case 46: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45)), vl
        Case 47: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46)), vl
        Case 48: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47)), vl
        Case 49: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48)), vl
        Case 50: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49)), vl
        Case 51: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50)), vl
        Case 52: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51)), vl
        Case 53: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52)), vl
        Case 54: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53)), vl
        Case 55: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53), idx(lb + 54)), vl
        Case 56: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53), idx(lb + 54), idx(lb + 55)), vl
        Case 57: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53), idx(lb + 54), idx(lb + 55), idx(lb + 56)), vl
        Case 58: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53), idx(lb + 54), idx(lb + 55), idx(lb + 56), idx(lb + 57)), vl
        Case 59: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53), idx(lb + 54), idx(lb + 55), idx(lb + 56), idx(lb + 57), idx(lb + 58)), vl
        Case 60: Assign ary(idx(lb), idx(lb + 1), idx(lb + 2), idx(lb + 3), idx(lb + 4), idx(lb + 5), idx(lb + 6), idx(lb + 7), idx(lb + 8), idx(lb + 9), idx(lb + 10), idx(lb + 11), idx(lb + 12), idx(lb + 13), idx(lb + 14), idx(lb + 15), idx(lb + 16), idx(lb + 17), idx(lb + 18), idx(lb + 19), idx(lb + 20), idx(lb + 21), idx(lb + 22), idx(lb + 23), idx(lb + 24), idx(lb + 25), idx(lb + 26), idx(lb + 27), idx(lb + 28), idx(lb + 29), idx(lb + 30), idx(lb + 31), idx(lb + 32), idx(lb + 33), idx(lb + 34), idx(lb + 35), idx(lb + 36), idx(lb + 37), idx(lb + 38), idx(lb + 39), idx(lb + 40), idx(lb + 41), idx(lb + 42), idx(lb + 43), idx(lb + 44), idx(lb + 45), idx(lb + 46), idx(lb + 47), idx(lb + 48), idx(lb + 49), idx(lb + 50), idx(lb + 51), idx(lb + 52), idx(lb + 53), idx(lb + 54), idx(lb + 55), idx(lb + 56), idx(lb + 57), idx(lb + 58), idx(lb + 59)), vl
        Case Else:
    End Select
End Sub

Sub setAryMbyS(mAry, sAry)
    Dim i As Long, n As Long
    Dim sp, lsp, idx, vl
    sp = getAryShape(mAry)
    lsp = getAryShape(mAry, "L")
    n = getAryNum(mAry)
    For i = 0 To n - 1
        idx = mkIndex(i, sp, lsp)
        vl = getAryAt(sAry, i, 0)
        Call setElm(vl, mAry, idx)
    Next i
End Sub

Function getArySbyM(mAry, Optional bs As Long = 0)
    Dim n As Long, i As Long
    Dim sp, lsp, idx, vl
    sp = getAryShape(mAry)
    lsp = getAryShape(mAry, "L")
    n = getAryNum(mAry)
    ReDim ret(bs To bs + n - 1)
    For i = 0 To n - 1
        idx = mkIndex(i, sp, lsp)
        vl = getElm(mAry, idx)
        Call setAryAt(ret, i, vl, 0)
    Next i
    getArySbyM = ret
End Function

Function reshapeAry(ary, sp, Optional bs As Long = 0)
    Dim ret
    ret = mkMAry(sp, bs)
    Call setAryMbyS(ret, ary)
    reshapeAry = ret
End Function

Function calc(num1 As Variant, num2 As Variant, symbol As String)
    Dim ret
    Select Case symbol
        Case "+": ret = num1 + num2
        Case "-": ret = num1 - num2
        Case "*": ret = num1 * num2
        Case "/": ret = num1 / num2
        Case "\": ret = num1 \ num2
        Case "%": ret = num1 Mod num2
        Case "^": ret = num1 ^ num2
        Case Else
    End Select
    calc = ret
End Function

Function calcAry(ary1, ary2, symbol As String)
    Dim n As Long, i As Long
    n = lenAry(ary1)
    ReDim ret(0 To n - 1)
    For i = 0 To n - 1
        ret(i) = calc(getAryAt(ary1, i, 0), getAryAt(ary2, i, 0), symbol)
    Next i
    calcAry = ret
End Function

Function calcMAry(ary1, ary2, symbol As String, Optional bs As Long = 0)
    Dim n As Long, dm As Long, i As Long
    Dim ret, vl, sp1, sp2, lsp1, lsp2, lsp0, idx, idx0, idx1, idx2
    sp1 = getAryShape(ary1)
    sp2 = getAryShape(ary2)
    lsp1 = getAryShape(ary1, "L")
    lsp2 = getAryShape(ary2, "L")
    n = getAryNum(ary1)
    dm = lenAry(sp1)
    ret = mkMAry(sp1, bs)
    lsp0 = mkSameAry(bs, dm)
    For i = 0 To n - 1
        idx = mkIndex(i, sp1)
        idx1 = calcAry(idx, lsp1, "+")
        idx2 = calcAry(idx, lsp2, "+")
        idx0 = calcAry(idx, lsp0, "+")
        vl = calc(getElm(ary1, idx1), getElm(ary2, idx2), symbol)
        Call setElm(vl, ret, idx0)
    Next i
    calcMAry = ret
End Function

Function mkMAry(sp, Optional bs As Long = 0)
    Dim n As Long
    Dim ub, lb
    n = lenAry(sp)
    ub = calcAry(sp, mkSameAry(bs - 1, n), "+")
    lb = LBound(ub)
    Dim ret
    Select Case n
        Case 1: ReDim ret(bs To ub(lb))
        Case 2: ReDim ret(bs To ub(lb), bs To ub(lb + 1))
        Case 3: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2))
        Case 4: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3))
        Case 5: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4))
        Case 6: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5))
        Case 7: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6))
        Case 8: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7))
        Case 9: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8))
        Case 10: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9))
        Case 11: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10))
        Case 12: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11))
        Case 13: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12))
        Case 14: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13))
        Case 15: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14))
        Case 16: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15))
        Case 17: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16))
        Case 18: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17))
        Case 19: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18))
        Case 20: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19))
        Case 21: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20))
        Case 22: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21))
        Case 23: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22))
        Case 24: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23))
        Case 25: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24))
        Case 26: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25))
        Case 27: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26))
        Case 28: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27))
        Case 29: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28))
        Case 30: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29))
        Case 31: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30))
        Case 32: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31))
        Case 33: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32))
        Case 34: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33))
        Case 35: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34))
        Case 36: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35))
        Case 37: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36))
        Case 38: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37))
        Case 39: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37), bs To ub(lb + 38))
        Case 40: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37), bs To ub(lb + 38), bs To ub(lb + 39))
        Case 41: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37), bs To ub(lb + 38), bs To ub(lb + 39), bs To ub(lb + 40))
        Case 42: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37), bs To ub(lb + 38), bs To ub(lb + 39), bs To ub(lb + 40), bs To ub(lb + 41))
        Case 43: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37), bs To ub(lb + 38), bs To ub(lb + 39), bs To ub(lb + 40), bs To ub(lb + 41), bs To ub(lb + 42))
        Case 44: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37), bs To ub(lb + 38), bs To ub(lb + 39), bs To ub(lb + 40), bs To ub(lb + 41), bs To ub(lb + 42), bs To ub(lb + 43))
        Case 45: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37), bs To ub(lb + 38), bs To ub(lb + 39), bs To ub(lb + 40), bs To ub(lb + 41), bs To ub(lb + 42), bs To ub(lb + 43), bs To ub(lb + 44))
        Case 46: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37), bs To ub(lb + 38), bs To ub(lb + 39), bs To ub(lb + 40), bs To ub(lb + 41), bs To ub(lb + 42), bs To ub(lb + 43), bs To ub(lb + 44), bs To ub(lb + 45))
        Case 47: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37), bs To ub(lb + 38), bs To ub(lb + 39), bs To ub(lb + 40), bs To ub(lb + 41), bs To ub(lb + 42), bs To ub(lb + 43), bs To ub(lb + 44), bs To ub(lb + 45), bs To ub(lb + 46))
        Case 48: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37), bs To ub(lb + 38), bs To ub(lb + 39), bs To ub(lb + 40), bs To ub(lb + 41), bs To ub(lb + 42), bs To ub(lb + 43), bs To ub(lb + 44), bs To ub(lb + 45), bs To ub(lb + 46), bs To ub(lb + 47))
        Case 49: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37), bs To ub(lb + 38), bs To ub(lb + 39), bs To ub(lb + 40), bs To ub(lb + 41), bs To ub(lb + 42), bs To ub(lb + 43), bs To ub(lb + 44), bs To ub(lb + 45), bs To ub(lb + 46), bs To ub(lb + 47), bs To ub(lb + 48))
        Case 50: ReDim ret(bs To ub(lb), bs To ub(lb + 1), bs To ub(lb + 2), bs To ub(lb + 3), bs To ub(lb + 4), bs To ub(lb + 5), bs To ub(lb + 6), bs To ub(lb + 7), bs To ub(lb + 8), bs To ub(lb + 9), bs To ub(lb + 10), bs To ub(lb + 11), bs To ub(lb + 12), bs To ub(lb + 13), bs To ub(lb + 14), bs To ub(lb + 15), bs To ub(lb + 16), bs To ub(lb + 17), bs To ub(lb + 18), bs To ub(lb + 19), bs To ub(lb + 20), bs To ub(lb + 21), bs To ub(lb + 22), bs To ub(lb + 23), bs To ub(lb + 24), bs To ub(lb + 25), bs To ub(lb + 26), bs To ub(lb + 27), bs To ub(lb + 28), bs To ub(lb + 29), bs To ub(lb + 30), bs To ub(lb + 31), bs To ub(lb + 32), bs To ub(lb + 33), bs To ub(lb + 34), bs To ub(lb + 35), bs To ub(lb + 36), bs To ub(lb + 37), bs To ub(lb + 38), bs To ub(lb + 39), bs To ub(lb + 40), bs To ub(lb + 41), bs To ub(lb + 42), bs To ub(lb + 43), bs To ub(lb + 44), bs To ub(lb + 45), bs To ub(lb + 46), bs To ub(lb + 47), bs To ub(lb + 48), bs To ub(lb + 49))
        Case Else:
    End Select
    mkMAry = ret
End Function

Function l_(ParamArray argAry() As Variant)
    'works like function array()
    Dim ary As Variant
    ary = argAry
    l_ = ary
End Function

Sub setMArySeq(ary, Optional first = 1, Optional step = 1)
    Dim num As Long, i As Long
    Dim sp, lsp, idx, vl
    sp = getAryShape(ary)
    lsp = getAryShape(ary, "L")
    num = getAryNum(ary)
    vl = first
    For i = 0 To num - 1
        idx = mkIndex(i, sp, lsp)
        'vl = first + i0 * step
        Call setElm(vl, ary, idx)
        vl = vl + step
    Next i
End Sub

Function mkMSameAry(vl, sp, Optional bs As Long = 0)
    Dim n As Long, num As Long, i As Long
    Dim ret, lsp, idx
    ret = mkMAry(sp, bs)
    n = lenAry(sp)
    sp = getAryShape(ret)
    lsp = mkSameAry(bs, n)
    num = getAryNum(ret)
    For i = 0 To num - 1
        idx = mkIndex(i, sp, lsp)
        Call setElm(vl, ret, idx)
    Next i
    mkMSameAry = ret
End Function

Function mkMArySeq(sp, Optional first = 1, Optional step = 1, Optional bs As Long = 0)
    Dim ret
    ret = mkMAry(sp, bs)
    Call setMArySeq(ret, first, step)
    mkMArySeq = ret
End Function

Function uniqueAry(ary)
    Dim dic As Dictionary
    Set dic = CreateObject("Scripting.Dictionary")
    For Each elm In ary
        If Not dic.exists(elm) Then
            dic.Add elm, Empty
        End If
    Next
    ret = dic.keys
    uniqueAry = ret
End Function

Sub Assign(ByRef Variable As Variant, ByVal Value As Variant)
    If IsObject(Value) Then
        Set Variable = Value
    Else
        Variable = Value
    End If
End Sub
