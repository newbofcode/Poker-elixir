#CPS506- Elixir Assignment
#Yong Kang He - Worked alone
#SN: 500570639
defmodule Poker do
    def deal(list) do
        p1 = List.delete_at(list,1)|> List.delete_at(2)
        p2 = List.delete_at(list,0)|> List.delete_at(1)
        rank10 = highCard(p1,p2)
        rankDups = getDups(p1,p2)
        flush = getFlush(p1,p2)
        stright = getStright(p1,p2)

        rank = List.last(rankDups)

        cond do
            List.last(stright) == :rank1 -> stright |> Enum.drop(-1)|>Enum.sort() |> makeString()
            List.last(stright) == :rank2 -> stright |> Enum.drop(-1)|>Enum.sort() |> makeString()
            List.last(rankDups) == :rank3 -> rankDups |> Enum.drop(-1)|> makeString()
            List.last(rankDups) == :rank4 -> rankDups|> Enum.drop(-1)|> makeString()
            List.last(flush) == :rank5 -> flush |> Enum.drop(-1)|> makeString()
            List.last(stright) == :rank6 -> stright |> Enum.drop(-1)|>Enum.sort() |> makeString()
            List.last(rankDups) == :rank7 -> rankDups |> Enum.drop(-1)|> makeString()
            List.last(rankDups) == :rank8 -> rankDups |> Enum.drop(-1)|> makeString()
            List.last(rankDups) == :rank9 -> rankDups |> Enum.drop(-1)|> makeString()
            true -> makeString(rank10)
        end

        
    end

    def getStright(p1,p2) do
        royal1 = findRoyal(p1)
        royal2 = findRoyal(p2)
        royal1Flush = findSflush(royal1)
        royal2Flush = findSflush(royal2)

        a = List.first(p1)
        b = List.first(tl p1)
        c = List.first(p2)
        d = List.first(tl p2)

        p1a = findStright(p1,a)
        p1b = findStright(p1,b)
        p2c = findStright(p2,c)
        p2d = findStright(p2,d)
        p1best = fiveCardStrightcheck(p1a,p1b)
        p2best = fiveCardStrightcheck(p2c,p2d)
        s1Flush = findSflush(p1best)
        s2Flush = findSflush(p2best)
        p1bestLen = length p1best 
        p2bestLen = length p2best
        cond do
            ((length royal1Flush) == 5) && ((length royal2Flush) == 5) -> highestHand(royal1Flush,royal2Flush) ++ [:rank1]
            (length royal1Flush) == 5 -> royal1Flush ++ [:rank1]
            (length royal2Flush) == 5 -> royal2Flush ++ [:rank1]
            ((length s1Flush) == 5) && ((length s2Flush) == 5) -> highestHand(s1Flush,s2Flush) ++ [:rank2]
            (length s1Flush) == 5 -> s1Flush ++ [:rank2]
            (length s2Flush) == 5 -> s2Flush ++ [:rank2]
            (((length royal1) == 5) && ((length royal2) ==5 )) -> highestHand(royal1,royal2) ++ [:rank6]
            (length royal1) == 5 -> royal1 ++ [:rank6]
            (length royal2) == 5 -> royal2 ++ [:rank6]
            (p1bestLen == p2bestLen) && (p1bestLen == 5) -> highestHand(p1best,p2best) ++ [:rank6]
            p1bestLen == 5 -> p1best ++ [:rank6]
            p2bestLen == 5 -> p2best ++ [:rank6]
            true -> []
                
        end
        
    end
    def findSflush(h1) do
        h1len = length h1
        cond do
            h1len == 5 -> flush((h1 -- [hd h1]),(hd h1),[])
            true -> []
        end
    end
    def findRoyal(hand) do
        a = makeCard(List.first(hand))
        b = makeCard(List.first(tl hand))
        sortedhand = hand |> Enum.sort(&(makeCard(rem(&1,13)) <= makeCard(rem(&2,13)))) |> Enum.take(-5)
        remhand = sortedhand |> Enum.map(&makeCard(rem(&1,13)))
        case remhand do
            [10,11,12,13,14] -> sortedhand
            _ -> []
        end

    end

    def fiveCardStrightcheck(h1,h2) do
        h1len = length h1
        h2len = length h2 
        cond do
            (h1len == h2len) && (h1len == 5) -> highestHand(h1,h2)
            h1len == 5 -> h1 
            h2len == 5 -> h2 
            true -> []
        end
    end

    def findStright(p1,handcard) do
        p1pos = ((p1 |> Enum.sort(&(aces(makeCard(rem(&1,13)))) <= aces(makeCard(rem(&2,13))))) -- [handcard])
        p1pos = strightPos(p1pos,handcard,[],1)
        p1neg = ((p1 |> Enum.sort(&(aces(makeCard(rem(&1,13)))) >= aces(makeCard(rem(&2,13))))) -- [handcard])
        p1neg = strightNeg(p1neg,handcard,[],1)
        p1neg ++ p1pos

    end

    def strightNeg([],num,list,x) do
        Enum.take(list,4)
    end
    def strightNeg([h|t],num,list,x) do
        if (aces(makeCard(rem(h,13))) == aces(makeCard(rem(num,13))) - x) do
            strightNeg(t,num,list ++ [h], x + 1)
        else
            strightNeg(t,num,list,x)
        end
        
    end

    def strightPos([],num,list,x) do
        Enum.take(([num] ++ list),5)
    end
    def strightPos([h|t],num,list,x) do
        if (aces(makeCard(rem(h,13))) == aces(makeCard(rem(num,13)))+x) do
            strightPos(t,num,list ++ [h], x + 1)
        else
            strightPos(t,num,list,x)
        end
        
    end

    def getFlush(p1,p2) do
        a = List.first(p1)
        b = List.first(tl p1)
        c = List.first(p2)
        d = List.first(tl p2)

        p1a = flush((p1 -- [a]),a,[])
        p1b = flush((p1 -- [b]),b,[])
        p2c = flush((p2 -- [c]),c,[])
        p2d = flush((p2 -- [d]),d,[])

        p1best = flushCompare(p1a,p1b)
        p2best = flushCompare(p2c,p2d)
        p1bestLen = length p1best 
        p2bestLen = length p2best 

        cond do
            (p1bestLen == 5) && (p2bestLen == 5) -> highestHand(p1best,p2best) ++ [:rank5]
            p1bestLen == 5 -> p1best ++ [:rank5]
            p2bestLen == 5 -> p2best ++ [:rank5]
            true -> [] 
        end


    end

    def flushCompare(h1,h2) do
        h1playercard = Enum.take(h1,-1)
        h2playercard = Enum.take(h2,-1)
        h1new = Enum.drop(h1,-1) |> Enum.sort() |> Enum.take(-4)
        h2new = Enum.drop(h2,-1) |> Enum.sort() |> Enum.take(-4)
        h1nLen = length h1new
        h2nLen = length h2new

        cond do
            (h1nLen == 4) && (h2nLen == 4) -> highestHand((h1new ++ h1playercard),(h2new ++ h2playercard))
            h1nLen == 4 ->  h1new ++ h1playercard
            h2nLen == 4 -> h2new ++ h2playercard
            true -> []
                
        end

    end

    def highestHand(h1,h2) do
        h1sum = h1 |> Enum.map(&(makeCard(rem(&1,13)))) |> Enum.sum()
        h2sum = h2 |> Enum.map(&(makeCard(rem(&1,13)))) |> Enum.sum()
        cond do
            h1sum > h2sum -> h1 
            h1sum < h2sum -> h2 
            true -> h1
                
        end
    end



    def flush([],num,list) do
        list ++ [num]
    end
    def flush([h|t],num,list) do
        if (makeSuit(h) == makeSuit(num)) do
            flush(t,num,list ++ [h])
        else
            flush(t,num,list)
        end
        
    end

    def highCard(p1,p2) do
        p1h = Stream.drop(p1,-5) |> Enum.sort()
        p2h = Stream.drop(p2,-5) |> Enum.sort()
        cond do
             List.last(p1h) > List.last(p2h) -> [List.last(p1h)]
             List.last(p1h) < List.last(p2h) -> [List.last(p2h)]
             List.last(p1h) == List.last(p2h) -> [Enum.max([hd(p1h),hd(p2h)])]
        end
    end


    def getDups(p1,p2) do
        a = List.first(p1)
        b = List.first(tl p1)
        c = List.first(p2)
        d = List.first(tl p2)
        pool1 = Stream.drop(p1,2) |> Stream.reject(&(rem(&1,13) == rem(a,13)))|>Enum.reject(&(rem(&1,13) == rem(b,13)))
        pool2 = Stream.drop(p2,2) |> Stream.reject(&(rem(&1,13) == rem(c,13)))|>Enum.reject(&(rem(&1,13) == rem(d,13)))


        p1a = dups((p1 -- [a]),a,[])
        p1b = dups((p1 -- [b]),b,[])
        p2c = dups((p2 -- [c]),c,[])
        p2d = dups((p2 -- [d]),d,[])
        p1best = dupCompare(p1a,p1b,pool1)
        p2best = dupCompare(p2c,p2d,pool2)
        p1Len = length p1best
        p2Len = length p2best
        cond do
            #rank3
            (p1Len == 5) && (p2Len == 5) && (List.last(p1best) == List.last(p2best)) && (List.last(p1best) == :rank3) -> fokTie(p1best,p2best)
            (p1Len == 5) && (List.last(p1best) == :rank3) -> p1best 
            (p2Len == 5) && (List.last(p1best) == :rank3) -> p2best 
            #rank4
            (p1Len == 6) && (p2Len == 6) -> fhTie(p1best,p2best)
            (p1Len == 6) -> p1best 
            (p2Len == 6) -> p2best 
            #triple
            (p1Len == 4) && (p2Len == 4) -> fokTie(p1best,p2best)
            (p1Len == 4) -> p1best 
            (p2Len == 4) -> p2best
            #2pair
            (p1Len == 5) && (p2Len == 5) -> doubTie(p1best,p2best)
            (p1Len == 5) -> p1best 
            (p2Len == 5) -> p2best 
            #pair
            (p1Len == 3) && (p2Len == 3) -> doubTie(p1best,p2best)
            (p1Len == 3) -> p1best 
            (p2Len == 3) -> p2best
            true -> []
        end
       
        
    end
    def doubTie(p1,p2) do
        p1hand = p1|> Stream.drop(-1) |> Enum.map(&(makeCard(rem(&1,13))))|> Enum.uniq()
        p2hand = p2|> Stream.drop(-1) |> Enum.map(&(makeCard(rem(&1,13)))) |> Enum.uniq()
        p1highest = Enum.max(p1hand)
        p1lowest = Enum.min(p1hand)
        p2highest = Enum.max(p2hand)
        p2lowest = Enum.min(p2hand)
        cond do
            (p1highest == p2highest) && (p1lowest > p2lowest) -> p1 
            (p1highest == p2highest) && (p1lowest < p2lowest) -> p2 
            p1highest > p2highest -> p1 
            p1highest < p2highest -> p2 
            true -> p1 
        end
        
    end


    def fokTie(p1,p2) do
        cond do
            makeCard(rem((hd p1),13)) > makeCard(rem((hd p2),13)) -> p1 
            makeCard(rem((hd p1),13)) < makeCard(rem((hd p2),13)) -> p2 
            true -> p1
        end

    end
    def fhTie(p1,p2) do
        p1hand = Enum.drop(p1,-1)
        p2hand = Enum.drop(p2,-1)
        a = makeCard(rem(List.first(p1hand),13))
        b = makeCard(rem(List.last(p1hand),13))
        c = makeCard(rem(List.first(p2hand),13))
        d = makeCard(rem(List.last(p2hand),13))
        cond do
             (a == c) && (b > d) -> p1
             (a == d) && (b > c) -> p1 
             (a == c) && (b < d) -> p2
             (a == d) && (b < c) -> p2 
             (b == c) && (a > d) -> p1
             (b == d) && (a > c) -> p1 
             (b == c) && (a < d) -> p2
             (b == d) && (a < c) -> p2 
            true -> p1    
        end
    end

    def dupCompare(a,b,c) do
        pool = c|> Enum.map(&(makeCard(rem(&1,13))))|> Enum.group_by(&(&1)) |> Map.values() |> Enum.sort(&((length &1) >= (length &2)))
        bestpool = hd(hd pool)
        bestpool = dups(c,bestpool,[]) |> Enum.drop(-1)
        bestpoolen = length(hd pool)
        len1 = length a
        len2 = length b
        aSorted = Enum.sort(a)
        bSorted = Enum.sort(b)
        samehand =  aSorted == bSorted
        cond do
            # four of a kind
            len1 == 4 -> a ++ [:rank3]
            len2 == 4 -> b ++ [:rank3]
            #full house
            (len1 == 3) && (len2 == 2) -> a ++ b ++ [:rank4]
            (len1 == 2) && (len2 == 3) -> a ++ b ++ [:rank4]
            (len1 == 3) && (bestpoolen == 2) -> a ++ bestpool ++ [:rank4]
            (len2 == 3) && (bestpoolen == 2) -> b ++ bestpool ++ [:rank4]
            (len1 == 2) && (bestpoolen == 3) -> a ++ bestpool ++ [:rank4]
            (len2 == 2) && (bestpoolen == 3) -> b ++ bestpool ++ [:rank4]
            #triple
            len1 == 3 -> a ++ [:rank7]
            len2 == 3 -> b ++ [:rank7]
            #2 pair
            (len2 == 2) && (len1 == 2) && (samehand == false) -> a ++ b ++ [:rank8]
            (len1 == 2) && (bestpoolen == 2) -> a ++ bestpool ++ [:rank8]
            (len2 == 2) && (bestpoolen == 2) -> a ++ bestpool ++ [:rank8]
            # pair
            len1 == 2 -> a ++ [:rank9]
            len2 == 2 -> b ++ [:rank9]
            true -> []
        end

    end
    def dups([],num,list) do
        list ++ [num]
    end
    def dups([h|t],num,list) do
        if (rem(h,13) == rem(num,13)) do
            dups(t,num,list ++ [h])
        else
            dups(t,num,list)
        end
        
    end



    def makeSuit(num) do
        suit = num/13
        cond do
            suit <= 1.0 -> "C"
            suit <= 2.0 -> "D"
            suit <= 3.0 -> "H"
            suit <= 4.0 -> "S" 
        end
    end
    def makeCard(num) do
        x = rem(num,13)
        case x do
            0 -> 13
            1 -> 14
            _ -> num
        end
    end
    def aces(num) do
        case num do
            14 -> 1
            _ -> num    
        end
    end
    def makeString(list) do
        #Enum.map(list,&(Enum.join(makeCard(&1))))
        Enum.map(list,&(Enum.join([aces(makeCard(rem(&1,13))),makeSuit(&1)])))
    end
end