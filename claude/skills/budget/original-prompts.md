# Original prompts that produced the correct budget analysis

These are the exact prompts from the first session where Claude correctly computed saved_that_month = £1,979.02. Saved here as reference for what worked.

---

## Prompt 1

hey, have a look at the latest csvs in Downloads. I've exported my full transactions for personal and joint. you have access to duckdb cli to query it more efficiently.

First, add a timestamp to the name of the files for now so we know when the extract was taken to both files.

Then familiarise yourself with the schema, what might be useful etc.

Our goal is to analyse the previous "months" so that you can come back with a report of my spending but crucially, understand the pattern of how I budget at the end/beginning of every month. There's a set of actions I take, you'd see them consistently moving money between accounts and pots.

Familiarise yourself with it and come back with what you think I do every month before month end to pre-emptively budget my month. Then note that we didn't do that this month. Then give me what you think the differences are of this month and the last few (like 3 is fine) and what you recommend i do for this month's budget. Bear in mind we're kind of doing it retroactively since I missed this month so we need to pretend like we were doing this on the 28th february 2026 at 23:59 for the sake of consistency.

This is a test where I test you on your outcomes so you need to pass as a financial understander/adviser. go give it a go

---

## Prompt 2 (corrections)

you got the weekly budget wrong. we send FROM the joint to ourselves (our weekly budget pot) every month, 550. It then auto fills the personal account on saturdays from that pot. we move it from the joint current account.

55 is sent fROM the joint to my personal bills pot. you got the order of some of these wrong. the max and other shared bills come from the personal, so every month I manually move some money from the joint current to my personal pot like bills in this case. Mila does the same for her own bills pot.

Again ggogle cloud storage is the other way, I think this comes out of my flex, so I take form joint (either bills joint or current account joint) to pay for it in my flex account.

We stopped the mortgage buffer because before we didn't have enough coming in to pay both rent and mortgage. Now we don't have rent so we don't need to do that.

It seems you also missed probably the most crucial part of all this which is really what I want to automate. Evvery month I put money aside for various things. One is holiday pot, another is safety net pot, another is the "house" pot (which we want to continue saving for for house renovations, furniture etc. Think like how the car pot just always adds money to it and then we use it when we need car things, like this but for the house), and then crucially I leave a precise amount of what is left, after all bills are paid, in the joint current account for us to spend. The point of this whole exercise is literally mostly for this. This is the point of it all. you missed it entirely.

Can you rerun your analysis and focus on the manual movements. Please reupdate your understanding of how money moves between accounts in the csvs because you got stuff like the weekly budget and manual personal account bills pot completely backwards.

finally, the IDEA is for you to return to me with what is left over for the month, taking into acocunt our earnings for the month, all the bills that "will come out" (though you already know what will come out since you can see past the 28th of Feb to see what happened, but ideally we would be doing this pre-emptively based on previous months) and then come back with one amount which if you look at the latest excel workbook I downloaded here: ~/Downloads/Budget Feb 2026.xlsm in the sheet "Editable - Budget" in the column "saved_that_month" is what it all comes down to. Then provide a suggestion of how to break this money up into the different pots I mentioned. Holiday, House, Safety net, and spending current join account.

Go

---

## Prompt 3 (skill creation request)

Nice, I like this. I think you now understand what we do.

Ok so the goal now is to create (at user level in my dot files symlinked to my user files) a command that's like /finances or something that we can replicate. Before we begin, let me re iterate the goal here.

We want something simple. The ideal scenario is I just type /finances or /monthly_budget or /budget Idk, something simple and then agent will search for downloaded extracted data from Downloads. Look for the csv or xslm files for what it is. If you can't find it, you ask the user to go download a fresh batch for each thing you will need. If it is there, but they're old (you should always start the session by checking today's date) you should query them and see if there's this month's data in there, if not ask the user.

Then run the numbers. Let's always cap it at most 6 month data. It's quite a lot. ALL maths and calculations NEED to be done either via duckdb or bash. We need to state the goal and the logic, not the exact numbers if that makes sense. We need to teach it to understand what the excercise we're doing. If we're running it, we need to check what date it is. For example if we're running it exactly at the end of the month then it prob will be fine. our salaries will come in, and bills are yet to happen. but if we do it slightly before and the salaries aren't in yet, we need to tell the user and stop. We need both salaries before continuing. If we do it after like we're doing now, it should be aware that it should still calculate it based off of the last day of the month, but then validate it against the real bits that have happened.

Then of course, the key part is the goal right. Again we don't want to teach it exactly what to do, but understand the feeling, the logic of what we're trying to do. We want to ultimately pro actively calculate how much money can we save that month right? So we look at previous months, see all the trasactions coming in. If there's a recurring new transaction for that month, call it out and flag it to the user. But ultimately what we want is to get that magic number. That's what this whole bit is for. then the other final bit is to give the split into the pots to budget intelligently. The user will take this on and do what is needed.

One thing to note is that we want to have this comparison to previous months for the past 6 months for each "saved_that_month", flex cost, after flex, income, exactly as you laid out there. What we want to call out here, is the differences. Like if the saved that month has moved +/- like 5% then we need to explain it quite substantially. detailed report on what made it go up or down this month in comparsion to previous months. I want to understand WHY every time. The agent should essentially feel like its at court having to prove itself why it got to this number every time. I will be very upset if I don't feel like it was explained thoroughly enough. The report should be UN-EMOTIONAL. Simple, direct. List the differeces, no need to write a whole narrative. I just need to be reminded what changed.

Then after all of this, the part at the end you said "actions still needed" you sohuld do that every time, but instead frame it almost like a prompt for another agent. Imaging this agent could move money around the accounts. Make it clear, simple and direct. I will be the one doing it (a human) but it should read like a prompt assuming i have monzo mcp access to move money around pots.

First, before we continue, do you understand? What do you think of this? Give me a review of what you think I want, why this is useful if you think it's useful, what you think could be improved before we create the command, and what the rough architecture will be here -- draw it with ascii so I can understand what you're thinkging.

only then I'll approve and then we can create the tool
