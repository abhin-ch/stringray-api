using System;

namespace StingrayNET.ApplicationCore.Specifications;

#nullable disable
public class Either_DEPCRECATED<TLeft, TRight>
{
    private readonly TLeft _left;
    private readonly TRight _right;

    private readonly bool _isLeft;
    public Either_DEPCRECATED(TLeft left)
    {
        _left = left;
        _isLeft = true;
    }
    public Either_DEPCRECATED(TRight right)
    {
        _right = right;
        _isLeft = false;
    }

    public TLeft GetLeft()
    {
        return _left;
    }

    public TRight GetRight()
    {
        return _right;
    }

    public T Match<T>(Func<TLeft, T> left, Func<TRight, T> right)
    {
        return _isLeft ? left(_left) : right(_right);
    }

    public void Match(Action<TLeft> left, Action<TRight> right)
    {
        if (_isLeft)
            left(_left);
        else right(_right);
    }
}
#nullable enable
