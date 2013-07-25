Pod::Spec.new do |s|
  s.name         = "Futility"
  s.version      = "1.0.1"
  s.summary      = "Some reusable iOS goodness, brought to you by Futurice."
  s.homepage     = "https://github.com/futurice/Futility"
  s.license      = { :type => "BSD-3", :file => 'LICENSE' }
  s.authors      = {
    "Ali Rantakari" => "ali.rantakari@futurice.com",
    "Juha Vähä-Herttua" => "juha.vaha-herttua@futurice.com",
    "Martin Richter" => "martin.richter@futurice.com",
    "Oleg Grenrus" => "oleg.grenrus@iki.fi",
    "Pyry Jahkola" => "pyry.jahkola@iki.fi"
  }
  s.source       = { :git => "https://github.com/futurice/Futility.git", :tag => "1.0.1" }
  s.source_files = 'Futility'
  s.platform     = :ios, '5.1'
  s.requires_arc = true
end
