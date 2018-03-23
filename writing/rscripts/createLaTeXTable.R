library(Hmisc)
	
createLatexTable = function(m, predictornames=c(),form="",d=data.frame())
{
	coefs = as.data.frame(summary(m)$coefficients)
	
	coefs[,1] = round(coefs[,1],digits=2)
	coefs[,2] = round(coefs[,2],digits=2)
	coefs[,3] = round(coefs[,3],digits=1)
	coefs[,4] = ifelse(coefs[,4] > .05, paste(">",round(coefs[,4],digits=2),sep=""), ifelse(coefs[,4] < .0001, "\\textbf{<.0001}", ifelse(coefs[,4] < .001,"\\textbf{<.001}", ifelse(coefs[,4] < .01, "\\textbf{<.01}", "\\textbf{<.05}"))))
	
	colnames(coefs) = c("Coef $\\beta$","SE($\\beta$)", "\\textbf{z}","$p$")
	coefs[,3] = NULL
	
	if (length(predictornames > 0))
	{
		prednames = data.frame(PName=row.names(coefs),NewNames=predictornames)#c("Intercept","Above BP","Accessible head noun.0","Accessible head noun.1","Grammatical function (subject).0","Grammatical function (subject).1","Animate head noun.0","Animate head noun.1","Head predictability.0","Head predictability.1","Constituent complexity.0","Constituent complexity.1","IPre.0","IPre.1","IHead.0","IHead.1","Head type (count).0","Head type (count).1"))
	} else {
		prednames = data.frame(PName=row.names(coefs),NewNames=row.names(coefs))		
	}
	
	row.names(coefs) = prednames$NewNames[prednames$PName == row.names(coefs)]
	
	latex(coefs,file="",title="",table.env=TRUE,booktabs=TRUE)
}
