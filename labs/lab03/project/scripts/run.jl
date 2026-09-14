# 1. Julia simülasyon hesaplamalarını çalıştır
println("Simulasyonlar calistiriliyor...")
include("daisyworld.jl")
include("daisyworld-luminosity.jl")

# 2. Raporu derlemek için report klasörüne geçip make komutunu tetikle
println("Rapor otomatik olusturuluyor...")
cd("../../report") do
    run(`make`)
end
println("Islem tamamlandi!")