using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.ApplicationCore.Interfaces;
public interface IRepositoryM<T, K> : IRepositoryS<T, K> where T : BaseProcedure where K : BaseOperation
{
    Task<K> Op_30(T model = null!);
    Task<K> Op_29(T model = null!);
    Task<K> Op_28(T model = null!);
    Task<K> Op_27(T model = null!);
    Task<K> Op_26(T model = null!);
    Task<K> Op_25(T model = null!);
    Task<K> Op_24(T model = null!);
    Task<K> Op_23(T model = null!);
    Task<K> Op_22(T model = null!);
    Task<K> Op_21(T model = null!);
    Task<K> Op_20(T model = null!);
    Task<K> Op_19(T model = null!);
    Task<K> Op_18(T model = null!);
    Task<K> Op_17(T model = null!);
    Task<K> Op_16(T model = null!);

}
