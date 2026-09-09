using ResumableFunctions
using ConcurrentSim
using Distributions
using DataFrames
using Random

@resumable function machine(
    env::Environment,
    repair_facility::Resource,
    spares::Store{Int},
    log_data::DataFrame,
    local_rng::AbstractRNG,
    dist_F::Distribution,
    dist_G::Distribution
)
    while true
        # 1. РАБОТА (Çalışma Aşaması)
        @yield timeout(env, rand(local_rng, dist_F))

        # 2. ПОЛОМКА (Bozulma ve İstatistik Kaydı)
        push!(log_data, (
            time = now(env),
            queue_length = length(repair_facility.put_queue),
            active_repairers = repair_facility.capacity - length(repair_facility.put_queue),
            spares_left = length(spares.items)
        ))

        # Depodan bir yedek parça al (yedek yoksa burada bekler)
        @yield get(spares)

        # 3. РЕМОНТ (Tamir Aşaması)
        @yield lock(repair_facility)
        
        @yield timeout(env, rand(local_rng, dist_G))
        
        @yield unlock(repair_facility)
        
        # Tamir edilen makineyi yedek parça olarak depoya geri koy
        @yield put(spares, 1)
    end
end

@resumable function start_sim_proc(
    env::Environment,
    repair_facility::Resource,
    spares::Store{Int},
    log_data::DataFrame,
    current_N::Int,
    S::Int,
    local_rng::AbstractRNG,
    F_dist::Distribution,
    G_dist::Distribution
)
    # Başlangıçta depoya S adet yedek parça ekle
    for _ in 1:S
        @yield put(spares, 1)
    end

    # N adet aktif çalışan makine sürecini başlat
    for i in 1:current_N
        @process machine(env, repair_facility, spares, log_data, local_rng, F_dist, G_dist)
    end
end