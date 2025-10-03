require 'timecop'

Before('@timecop') do
  Timecop.freeze(Time.local(2025, 10, 2, 15, 30, 0))
end

After('@timecop') do
  Timecop.return
end
