namespace :admin do
  namespace :currency do
    task :enabled do
      symbol = ask("Currency Symbol? ")
      enabled = ask("Disable (Enter anything). Enable (Enter \"enable\") ") == 'enable'

      Fortune::Currency.set_enabled(symbol, enabled)
      flogger.info "#{symbol} is #{enabled ? "enabled" : "disabled" }"
    end
  end
end
