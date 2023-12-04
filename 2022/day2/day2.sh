# https://adventofcode.com/2022/day/2
typeset -A winlosedraw=(
[A X]=draw [A Y]=win  [A Z]=lose  # rock(A) + (rock(X), paper(Y), scissor(Z)
[B X]=lose [B Y]=draw [B Z]=win   # paper(B) + "
[C X]=win  [C Y]=lose [C Z]=draw  # scissor(C)+ "
)

typeset -A scores=( [X]=1 [Y]=2 [Z]=3 [win]=6 [lose]=0 [draw]=3 )

# Answer 1

typeset -i score=0
typeset -i value
while read first second;do
    result=${winlosedraw[$first $second]}
    (( value=scores[$second] + scores[$result] ))
    (( score+=value ))
done < input.txt

echo "Answer 1: score is $score"

# Answer 2

typeset -A whattochoose=(
[A X]=Z [A Y]=X [A Z]=Y   # rock(A) + (lose(X), draw(Y), win(Z) ->  (rock(X), paper(Y), scissor(Z)
[B X]=X [B Y]=Y [B Z]=Z   # paper(B) + "
[C X]=Y [C Y]=Z [C Z]=X   # scissor(C)+ "
)

score=0
while read first wld;do
    second=${whattochoose[$first $wld]}
    result=${winlosedraw[$first $second]}
    (( value = scores[$second] + scores[$result] ))
    (( score+=value ))
done < input.txt

echo "Answer 2: score is $score"
