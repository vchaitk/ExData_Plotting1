
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

# This function takes the data frame and the filename to store the plot 
# in the given filePath
drawAndSavePlot <- function(data, filePath="plot4.png") {
    data$DateTime <- paste(data$Date, data$Time, sep = " ")
    png(filename = filePath, width = 480, height = 480, units = "px")
    x <- strptime(data$DateTime, "%d/%m/%Y %H:%M:%S")
    par(mfrow=c(2,2))
    y <- data$Global_active_power
    plot(x, y, type="l", xlab="", ylab="Global Active Power (kilowatts)")
    plot(x, data$Voltage, type="l", xlab="datetime", ylab="Voltage")
    # par(mfrow=c(2,2))
    y1 <- data$Sub_metering_1
    y2 <- data$Sub_metering_2
    y3 <- data$Sub_metering_3
    plot(x, y1, type="l", xlab="", ylab="Energy sub metering")
    lines(x, y2, col="red")
    lines(x, y3, col="green")
    legend("topright", 
           legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), 
           lwd=2, col=c("black", "red", "blue"))
    plot(x, data$Global_reactive_power, type="l", xlab="datetime", ylab="Global_reactive_power")
    dev.off()
}

# This is the main function that needs to be called in order to do the complete 
# data processing as well as plotting the graph over the period of 
# 2 days (2007-02-01 and 2007-02-02)
init <- function() {
    data <- preProcessAndGetData()
    drawAndSavePlot(data, "plot4.png")
}
