
library(shiny)

model <- readRDS("reduced_model.rds")

#user interface

ui <- fluidPage(
  
  titlePanel("Credit Risk Scoring Tool"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      numericInput(
        "income",
        "Annual Income (£)",
        value = 55000,
        min = 4000
      ),
      
      selectInput(
        "home",
        "Home Ownership",
        choices = c(
          "MORTGAGE",
          "OTHER",
          "OWN",
          "RENT"
        )
      ),
      
      numericInput(
        "emp_length",
        "Employment Length (years)",
        value = 4,
        min = 0,
        max = 60
      ),
      
      selectInput(
        "intent",
        "Loan Intent",
        choices = c(
          "DEBTCONSOLIDATION",
          "EDUCATION",
          "HOMEIMPROVEMENT",
          "MEDICAL",
          "PERSONAL",
          "VENTURE"
        )
      ),
      
      selectInput(
        "grade",
        "Loan Grade",
        choices = c(
          "A",
          "B",
          "C",
          "D",
          "E",
          "F",
          "G"
        )
      ),
      
      numericInput(
        "loan_amount",
        "Loan Amount (£)",
        value = 8000,
        min = 500,
        max = 35000
      ),
      
      numericInput(
        "interest_rate",
        "Interest Rate (%)",
        value = 10.99,
        min = 5.42,
        max = 23.22
      ),
      
      numericInput(
        "loan_percent_income",
        "Loan-to-Income Ratio (%)",
        value = 15,
        min = 0,
        max = 100
      ),
      
      actionButton(
        "calculate",
        "Calculate Risk"
      )
      
    ),
    
    mainPanel(
      
      h3("Credit Risk Assessment"),
      
      h4("Estimated Probability of Default"),
      textOutput("probability"),
      
      h4("Risk Segment"),
      textOutput("risk")
      
    )
    
  )
)

#action button creates a clickable button.
#text output(prob)- empty space to display estimated prob of default
#risk creates space for risk segment.

server <- function(input, output) {
  
  observeEvent(input$calculate, {
    
    new_borrower <- data.frame(
      
      person_income = input$income,
      
      person_home_ownership = factor(
        input$home,
        levels = c("MORTGAGE", "OTHER", "OWN", "RENT")
      ),
      
      person_emp_length = input$emp_length,
      
      loan_intent = factor(
        input$intent,
        levels = c(
          "DEBTCONSOLIDATION",
          "EDUCATION",
          "HOMEIMPROVEMENT",
          "MEDICAL",
          "PERSONAL",
          "VENTURE"
        )
      ),
      
      loan_grade = factor(
        input$grade,
        levels = c("A", "B", "C", "D", "E", "F", "G")
      ),
      
      loan_amnt = input$loan_amount,
      
      loan_int_rate = input$interest_rate,
      
      loan_percent_income = input$loan_percent_income / 100,
      
      emp_length_missing = FALSE
    )
    
    probability <- predict(
      model,
      newdata = new_borrower,
      type = "response"
    ) #asks based on what is learned from the training data what is the prob this 
    #borrower defaults.
    
    output$probability <- renderText({
      paste0(
        round(probability * 100, 1),
        "%"
      )
    })
    
    output$risk <- renderText({
      
      if (probability < 0.10) {
        "Low Risk"
        
      } else if (probability < 0.30) {
        "Medium Risk"
        
      } else {
        "High Risk"
      }
      
    })
    
  })
}

shinyApp(
  ui = ui,
  server = server
)






