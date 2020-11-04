# This app is *largely* based on the ShinyPsych package [cite]
# Nonetheless, this package does not have a strong focus on RT tasks.
# Here, we adapted some of its functionality and aesthetics for a numerical comparison task based on Dehaene, 1990, JEP:HPP

# Load pkgs, fns and num lists ====================================================
library(shiny);library(shinyjs);library(shinyWidgets)

# source pipeline and page layout fns
source("helper_fns.R"); source("page_fns.R")

# load number lists (following the design from Dehaene. 
# 4 trng trials + 116 exp trials (2 presentations of 58 numbers (29 smaller, 29 greater than the standard 65) )
load("www/num_list.Rda") 

# set the number of epxerimental trials you want to use to test the app (from 1 to 116)
ntr=4 

# set save dir (locally). You should have 4 subdirs within the save_dir: sessions, trng, exp & demog
save_dir=paste0(getwd(),"/data/")

# Load app pages' lists ====================================================
lists_dir="www/lists/"

# translate simple pages to HTML
instru.list = makePageList(fileName = paste0(lists_dir,"Instructions.txt"), globId = "Instructions")
consent.list =makePageList(fileName = paste0(lists_dir,"Consent.txt"), globId = "Consent")
endTrng.list = makePageList(fileName = paste0(lists_dir,"EndTraining.txt"), globId = "endTrng")
demog.list =  makePageList(fileName = paste0(lists_dir,"Demographics.txt"),  globId = "Demog")
goodbye.list =makePageList(fileName = paste0(lists_dir,"Goodbye.txt"),  globId = "Goodbye")

# Set pages IDs
pageIDs = c("Instructions",
            "Consent",
            "ITItrng",
            "ITIexp",
            "endTrng",
            "Trng",
            "Exp",
            "Demog",
            "Goodbye")

# Shiny UI ====================================================
ui = fixedPage(
  # App title (appears on browser window tag)
  title = "Numeros",      
  # progress bar throughout the whole app-flow
  progressBar(id = "pb1", value = 0, display_pct = FALSE,status = "primary"), 
  # for Shinyjs functions
  useShinyjs(),
  # include custom css and js scripts
  loadScripts(), 
  # to detect the device type (might be redundant with os/browser data)
  mobileDetect('isMobile'),
  # render reactive HTML from server
  uiOutput("MainAction")
)

# Shiny server ====================================================
server = function(input, output, session) {
  # get os and browser data
  shinyjs::runjs(browserdet) 
  
  # everything (HTML) is output in "MainAction"
  output$MainAction = renderUI( {
    PageLayouts()
  })
  
  # pick a random pre-ordered number-list and set ITIs
  set.seed(round( as.numeric(Sys.time() ) ) )
  list_idx=sample(ncol(exp_list_num),1)
  
  # set trng and exp list dfs and ITIs
  trng_trials=data.frame(trng_list,
                         "ITI"=runif(nrow(trng_list),.7,1)*1000 )
  
  exp_trials=data.frame("num"= exp_list_num[[list_idx]] , 
                          "truth"= exp_list_truth[[list_idx]], 
                          "ITI"= runif(nrow(exp_list_num),.7,1)*1000)[1:ntr,]
  
  # set a 3-letter random workerID
  wid =  paste(sample(letters,3),collapse = '') 
  
  # Reactives to store data during game
  trngData = reactiveValues(time = c(), resp=c() )
  expData  = reactiveValues(time = c(), resp=c() )
  
  # inicializo conteos de pags
  currVal = makeCtrlList(firstPage = "Instructions",globIds = pageIDs)  
  # HTML page layouts
  PageLayouts = reactive({
    #intro
    if (currVal$page == "Instructions") {  
        return(makePage(pageList = instru.list, pageNumber = currVal$Instructions.num,
                            globId = "Instructions", ctrlVals = currVal))   }
    if (currVal$page == "Consent"){
      return(makePage(pageList = consent.list, pageNumber = currVal$Consent.num,
                    globId = "Consent", ctrlVals = currVal)  )}
    
    #trng
    if (currVal$page == "ITItrng") {
      return(itiPage(ctrlVals = currVal, trng_trials))}
    
    if (currVal$page == "Trng") {
      return(trngPage(ctrlVals = currVal, trng_trials))}
    
    # fin prac
    if (currVal$page == "endTrng") {
      return( makePage(pageList = endTrng.list, pageNumber = currVal$endTrng.num,
                          globId = "endTrng", ctrlVals = currVal)) }
    
    #exp
    if (currVal$page == "ITIexp") {
      return(itiPage(ctrlVals = currVal, exp_trials))}
    
    if (currVal$page == "Exp") {
      return(expPage(ctrlVals = currVal, exp_trials))}
    

    #outro
    if (currVal$page == "Demog"){
      return(makePage(pageList = demog.list, pageNumber = currVal$Demog.num,
                    globId = "Demog", ctrlVals = currVal))}
    
    if (currVal$page == "Goodbye") {
      return(gbPage(pageList = goodbye.list, pageNumber = currVal$Goodbye.num,
                    globId = "Goodbye", ctrlVals = currVal))}
    
    if (currVal$page=="end"){
      shiny::stopApp()}
  })
  
  # Observe events ======================================
  observeEvent(input[["isMobile"]],{currVal$mobile=input$isMobile}) # get device type
  
  # Page Navigation ----------------------
  observeEvent(input[["Instructions_next"]],{
      nextPage(pageId = "Instructions", ctrlVals = currVal, nextPageId ="Consent" ,
                pageList = instru.list, globId = "Instructions")
  })
  
  observeEvent(input[["Consent_next"]],{
    shinyjs::runjs("document.body.style.cursor = 'none';") # no muestro mouse
    
    nextPage(pageId = "Consent", ctrlVals = currVal, nextPageId ="ITItrng" ,
              pageList = consent.list, globId = "Consent")
  })
  
  # TRNG ITI page complete
  observeEvent(input[["waitTrng"]], { currVal$page="Trng" })
  
  # TRNG trial page complete
  observeEvent(input[["trialNrpr"]], {
    updateProgressBar(session = session,id = "pb1", value = 100*(currVal$trngTrial/nrow(trng_trials) ) )
    appendTrngValues(ctrlVals = currVal, container = trng_trials,
                    input = input, trngData = trngData,
                    afterTrialPage = "ITItrng", afterLastTrialPage = "endTrng")
    
  })
  
  # last TRNG trial page complete
  observeEvent(input[["endTrng_next"]],{
    updateProgressBar(session = session,id = "pb1", value = 0 )
    shinyjs::runjs("document.body.style.cursor = 'none';") # no muestro mouse
    
    nextPage(pageId = "endTrng", ctrlVals = currVal, nextPageId ="ITIexp" ,
              pageList = endTrng.list, globId = "endTrng")
  })
  
  
  # EXP ITI page complete
  observeEvent(input[["waitExp"]], { currVal$page="Exp"})
  # EXP trial page complete
  observeEvent(input[["trialNr"]], {
    if(currVal$expTrial<nrow(exp_trials)) {
      updateProgressBar(session = session,id = "pb1", value = 100*(currVal$expTrial/nrow(exp_trials) ) )
      appendExpValues(ctrlVals = currVal, container = exp_trials, 
                      input = input, expData = expData,
                      afterTrialPage = "ITIexp", afterLastTrialPage = "Demog")
    }
    # if last trial
    else if(currVal$expTrial==nrow(exp_trials)) { 
      
      updateProgressBar(session = session,id = "pb1", value = 100*(currVal$expTrial/nrow(exp_trials) ) )
      appendExpValues(ctrlVals = currVal, container = exp_trials, 
                      input = input, expData = expData,
                      afterTrialPage = "ITIexp", afterLastTrialPage = "Demog")
      # save all data to local dir
      withProgress(message = "Guardando...", value = 0, {
        incProgress(.25)
        
        data.trng = list(  
          "id" = wid,
          "mobile"= input$isMobile,
          
          "resp" = trngData$resp, # 1 es MEnor, 2 es Mayor
          "RT" = trngData$time, # 
          
          "num" = trng_trials$practica, # numero mostrado 
          "truth" = trng_trials$resploc.pr, #Kground trugth
          "ITI" = trng_trials$ITI #Iti
        )
        
        data.exp = list(  
          "id" = wid,
          "mobile"= input$isMobile,
          
          "resp" = expData$resp, # 1 es MEnor, 2 es Mayor
          "RT" = expData$time, # 
          
          "num" = exp_trials$num, # numero mostrado 
          "truth" = exp_trials$truth, #Kground trugth
          "ITI" = exp_trials$ITI, #Iti
          "lista.id"=list_idx #which num list
        )

        data.session=list(reactiveValuesToList(session$clientData),input$osbrow)
        
        # Uncomment this to save data
        # saveData(data.session, 
        #           outputDir= paste0(save_dir,"sessions"),
        #           partId = data.exp$id, suffix = "_s")
        # 
        # saveData(data.trng,  
        #           outputDir= paste0(save_dir,"trng"),
        #           partId = data.exp$id, suffix = "_t")
        # 
        # saveData(data.exp, 
        #           outputDir= paste0(save_dir,"exp"),
        #           partId = data.exp$id, suffix = "_x")
      })}
    
  })
  
  
  # Save demog data ===================================
  # Demog page complete
  observeEvent(input[["Demog_next"]], {(
      
    withProgress(message = "Guardando...", value = 0, {
        incProgress(.25)
        data.demo=list(
          "id" = wid,
          "edu" = input$Demog_edu,
          "age" = input$Demog_age,
          "sex" = input$Demog_sex
          )
        # Uncomment this to save data
        # saveData(data.demo,  
        #           outputDir= paste0(save_dir,"demog"),
        #           partId = data.demo$id, suffix = "_d")
        # 
        # Compute final score for display (Correct: +2. Error/timeout: -1)
        currVal$score = 2*(sum(expData$resp==as.numeric(exp_trials$truth) ) ) -
          1*(sum(expData$resp!=as.numeric(exp_trials$truth) ) )
        
        currVal$page = "Goodbye"
    
      })
    
  )} )
  # Check inputs ----------------------
  observeEvent(reactiveValuesToList(input),{

    onInputEnable(pageId = "Consent", ctrlVals = currVal,
                   pageList = consent.list, globId = "Consent",
                   inputList = input)

    onInputEnable(pageId = "Demog", ctrlVals = currVal,
                   pageList = demog.list, globId = "Demog",
                   inputList = input)
    
  })
}

# Create app
shinyApp(ui = ui, server = server)