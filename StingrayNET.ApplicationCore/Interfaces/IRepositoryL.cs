using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.ApplicationCore.Interfaces;
public interface IRepositoryL<T, K> : IRepositoryM<T, K> where T : BaseProcedure where K : BaseOperation
{
    Task<K> Op_45(T model = null!);
    Task<K> Op_44(T model = null!);
    Task<K> Op_43(T model = null!);
    Task<K> Op_42(T model = null!);
    Task<K> Op_41(T model = null!);
    Task<K> Op_40(T model = null!);
    Task<K> Op_39(T model = null!);
    Task<K> Op_38(T model = null!);
    Task<K> Op_37(T model = null!);
    Task<K> Op_36(T model = null!);
    Task<K> Op_35(T model = null!);
    Task<K> Op_34(T model = null!);
    Task<K> Op_33(T model = null!);
    Task<K> Op_32(T model = null!);
    Task<K> Op_31(T model = null!);

}
