# make sure not to make calls too often

# get time of last call
get_IEEER_time <-
function()
{
   last <- as.numeric(Sys.getenv("IEEER_time"))
   ifelse(is.na(last), 0, last)
}

# set IEEER time to current
set_IEEER_time <-
function() {
    Sys.setenv(IEEER_time = as.numeric(Sys.time()))
}

# time since last call
time_since_IEEER <-
function() {
    as.numeric(Sys.time()) - get_IEEER_time()
}

# check for last time since call, and delay if necessary
# also re-set the IEEER_time
delay_if_necessary <-
function()
{
    # look for delay amount in options; otherwise set to default
    delay_amount <- getOption("IEEER_delay")
    if(is.null(delay_amount)) delay_amount <- 3

    if((timesince = time_since_IEEER()) < delay_amount)
        Sys.sleep(delay_amount - timesince)

    set_IEEER_time()
}
