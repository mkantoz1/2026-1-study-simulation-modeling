using ResumableFunctions
using ConcurrentSim
using Distributions
using DataFrames
using Random

@resumable function customer(env::Environment, server::Resource, id::Int, arrival_time::Float64, service_dist::Distribution, rng::AbstractRNG, times_data::DataFrame)
    # 1. Müşterinin sisteme geliş anına kadar bekle
    @yield timeout(env, arrival_time - now(env))
    arr_time = now(env)
    
    # 2. Servis için (kuyrukta) sıraya gir
    @yield request(server)
    
    # 3. Bekleme süresini hesapla ve istatistik tablosuna kaydet
    wait_time = now(env) - arr_time
    push!(times_data, (id, arr_time, wait_time))
    
    # 4. Servis hizmet süresini hesapla ve geçir
    service_time = rand(rng, service_dist)
    @yield timeout(env, service_time)
    
    # 5. İşlemi bitir ve kaynağı serbest bırak
    @yield release(server)
end