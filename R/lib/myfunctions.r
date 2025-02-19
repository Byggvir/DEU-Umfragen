Wochentage <- c("Mo","Di","Mi","Do","Fr","Sa","So")

RZahl <- function (b, SeriellesIntervall = 4) {
  
  return (round(exp(SeriellesIntervall*b),3))
  
}

limbounds <- function (x, zeromin=TRUE) {
  
  if (zeromin == TRUE) {
    range <- c(0,max(x,na.rm = TRUE))
  } else
  { range <- c(min(x, na.rm = TRUE),max(x,na.rm = TRUE))
  }
  if (range[1] != range[2])
  {  factor <- 10^(floor(log10(range[2]-range[1])))
  } else {
    factor <- 1
  }
  
  # print(factor)
  return ( c(floor(range[1]/factor),ceiling(range[2]/factor)) * factor) 
}


hn_round <- function ( votes, nseats = 100) {
  
  # Sum of votes
  S = sum(votes)
  
  # First round of seat allocation
  
  votes_per_seat = S/nseats             # How many votes are needed for a seat
  seats = floor(votes/votes_per_seat)   # Allocate whole seats according to vote share
  remaining_seats = nseats - sum(seats) # How many seats remain unallocated

  # 2. Second round of seat allocation
  
  # 2.1 How many votes were ignored? Parts of a vote are allowed
  unused_votes = votes - votes_per_seat * seats   
  
  # 2.2 Determine the ranking of the remaining voting shares
  rank_unused_votes = length(votes) - rank(unused_votes, ties.method = 'random') + 1 
  
  # 2.3 Distribute the unallocated seats according to rank
  
  seats[rank_unused_votes <= remaining_seats ] = seats[rank_unused_votes <= remaining_seats ] + 1 
  
  return (seats)
  
}

umfrage_error <- function (n = 1000, p=0.5) {
  
  return (2*sqrt((1-p)*p/n))
  
}
