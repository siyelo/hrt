code_splits = CodeSplit.includes(:activity).select{ |a| a.activity.blank? }
code_splits_total = code_splits.length

code_splits.each_with_index do |code_split, index|
  puts "Removing Code Split #{index+1}/#{code_splits_total}"
  code_split.destroy
end
