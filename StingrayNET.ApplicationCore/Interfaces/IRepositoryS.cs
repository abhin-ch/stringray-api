using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Interfaces;
public interface IRepositoryS<T, K> where T : BaseProcedure where K : BaseOperation
{
    Task<K> Op_15(T model = null!);
    Task<K> Op_14(T model = null!);
    Task<K> Op_13(T model = null!);
    Task<K> Op_12(T model = null!);
    Task<K> Op_11(T model = null!);
    Task<K> Op_10(T model = null!);
    Task<K> Op_09(T model = null!);
    Task<K> Op_08(T model = null!);
    Task<K> Op_07(T model = null!);
    Task<K> Op_06(T model = null!);
    Task<K> Op_05(T model = null!);
    Task<K> Op_04(T model = null!);
    Task<K> Op_03(T model = null!);
    Task<K> Op_02(T model = null!);
    Task<K> Op_01(T model = null!);
}
