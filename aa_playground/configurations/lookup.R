# Aleph Alpha Price Table-------------------------------------------------------
model_price = matrix(c(0.006, 0.009, 0.035, 
                       0.0075, 0.01125, 0.04375
), ncol=1, byrow=TRUE)
model_price = as.table(model_price)
colnames(model_price) = c('price per 1.000 token')
rownames(model_price) <- c('luminous-base','luminous-extended','luminous-supreme',
                           'luminous-base-control','luminous-extended-control','luminous-supreme-control')

task_factor = matrix(cbind(
                  c(1.0, 1.1, 1.3), 
                  c(1.1, 1.1, 0)
                  ), ncol = 2, byrow = TRUE)

colnames(task_factor) = c('input','output')
rownames(task_factor) = c('complete','evaluate','embed')
