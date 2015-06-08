
# This function helps in pre-processing and loading data and reduces the memory usage
# The original dataset is downloaded and put in this folder ("exdata-data-household_power_consumption.zip")
preProcessAndGetData <- function() {
    #Unzip and open the file containing original data
    unzip("./exdata-data-household_power_consumption.zip")
    data_location <- "./household_power_consumption.txt"
    raw_dataFile <- file(data_location, "r")
    processed_data_filePath <- "Electric_Power_Consumption_1min_Sampling.csv"
    processed_dataFile <- file(processed_data_filePath, "w")
    
    #Read and write the header from the file
    lines <- readLines(raw_dataFile, n=1)
    writeLines(lines, processed_dataFile)
    chunkSize <- 100000
    #Process lines from the full dataset and get the refined data in chunks
    while(length(lines)) {
        lineIndex <- grep("^[1-2]/2/2007", lines)
        if(length(lineIndex)) {
            writeLines(lines[lineIndex], processed_dataFile)
        }
        lines <- readLines(raw_dataFile, chunkSize)
    }
    close(processed_dataFile)
    close(raw_dataFile)
    
    #Load the processed data to a data frame and return the data frame
    data <- read.csv(processed_data_filePath, header = TRUE, sep=";", 
                     na.strings = "?", skipNul = TRUE)
    
    #cleanup the extracted files
    file.remove(processed_data_filePath)
    file.remove(data_location)
    
    data
}

# This function takes the data frame and the filename to store the plot.
# It draws a PNG line graph of Global Active Power in the data frame and stores
# it in the given filePath
drawAndSavePlot <- function(data, filePath="plot2.png") {
    data$DateTime <- paste(data$Date, data$Time, sep = " ")
    x <- strptime(data$DateTime, "%d/%m/%Y %H:%M:%S")
    y <- data$Global_active_power
    png(filename = filePath, width = 480, height = 480, units = "px")
    plot(x, y, type="l", xlab="", ylab="Global Active Power (kilowatts)")
    dev.off()
}

# This is the main function that needs to be called in order to do the complete 
# data processing as well as plotting the line graph for the Global Active Power 
# over the period of 2 days (2007-02-01 and 2007-02-02)
init <- function() {
    data <- preProcessAndGetData()
    drawAndSavePlot(data, "plot2.png")
}
