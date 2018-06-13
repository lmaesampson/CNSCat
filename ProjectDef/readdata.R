require(readstata13)
dat <- read.dta13("cnsfinall2.dta",convert.factors = FALSE)
##############################################################
# subset to clincial measures and final outcomes

features <- c(
  "indate", #text: date of admission YYYY-MM-DD
  #inclusion measures
  "incblant9", #binary: if child <9m, Blantyre score <4  
  "incblant",  #binary: if child >=9m, Blantyre score <4 
  "incglasg",  #binary: Glasgow score <15
  "incprost",  #binary: if <9m and unable to breastfeed OR >9m and unable to sit unassisted   
  "inchypot",  #binary: hypotonic   
  "inchypert", #binary: hypertonic
  "incirrit",  #binary: irritable
  "inchead",   #binary: headache severe enough to require hospitalization
  "incphoto",  #binary: phytophobic
  "incneck",   #binary: neck stiffness
  "incfont",   #binary: bulging fontanel
  "incneuro",  #binary: is there a focal neruological sign
  #"incneurosp", #open ended, if incneuro=T, what is focal neurological sign?
  "incseiza",  #binary: prolonged, mutliple, or partial seizure on admission   
  "incseizh", #binary: history of prolonged, mutliple, or partial seizure in last 48h
  "inckern",  #binary: Kerning sign (children >18m)
  "incbrud",  #binary: Brudzinski sign (children >18m)  
  "incpurp",  #binary: Purpura
  "inccheyn", #binary Cheyne stokes breathing
  "critage",  #binary: is patient [2m-12y] inclusion age criteria
  "critfev",  #binary: does patient have fever or history of fever -- NA in children <9m
  #lumbar puncture measures -- was there a contraindication for a lumbar puncture at inclusion
  "clppupsize", #binary: abnormality of pupil size and reaction
  "clpocul",    #binary: absence of oculocephalic reflex, fixed oculomotor deviation of the eyes
  "clpdecer",   #binary: Decerebrate / decorticate posture
  "clpneuro",   #binary: focal neurological signs
  "clpresp",    #binary: Respiratory abnormalities 
  "clppapiled", #binary: Papilledema
  "clpinf",     #binary: Local infection in the area through which the needle will have to pass
  "clpbleed",   #binary: Signs of bleeding disorders; coagulopathy/thrombocytopenia
  "clpcard",    #binary: Cardio-respiratory compromise which may be exacerbated by the LP
  "clptrauma",  #binary: Acute trauma of the spinal cord
  #medical history
  "sex",        #binary: sex M/F
  "dob",        #text: date of birth -- YYYY-MM-DD
  "dobdk",      #binary: date of birth unkonwn
  "ageyrs",     #integer: age years
  "agemth",     #integer: age months -- total age is both Y+M
  "mhhosp",     #binary: history of hospitalizaiton in the previous month
  "mhhospad",   #text: date of prior hospitalization admission
  "mhhospdur",  #integer: duraiton of prior hosptalization (days)
  "mhdevsp",    #text: signivicant developmental disability 
  "mhsickle",   #binary: sickle cell disease  
  "mhchronstat", #binary: presence of chronic disease
  "mhchronsp",  #text: chronic disease
  #vaccine history
  "vacbcg",     #categorical: BCG vaccine for tuberculosis 1=Y w/card, 2=Y verbal, 3=no, 4=UNK
  "vacmeasles", #as vacbcg for measles vaccine
  "vachib1",    #as vacbcg for first dose of Hib vaccine
  "vachib2",    #as vacbcg for second dose of Hib vaccine
  "vachib3",    #as vacbcg for third dose of Hib vaccine
  "vacmen",    #as vacbcg for meningitis vaccine
  "vacpneumo", #as vacbcg for pneumococcal vaccine
  #clincial measures 
  "abdpain",    #binary: abdominal pain at inclusion 
  "vom",        #binary: vomiting >2 episodes in 24h
  "diar",       #binary: diarrhoea >3 stools in 24h
  "head",       #binary: headache
  "muscle",     #binary: muscle/joint ache
  "conv",       #binary: convulsions
  #vital signs
  "temp",       #numeric: temperature in celsius 
  "card",       #integer: heartrate bpm
  "resp",       #integer: respiration pm
  "sbp",        #integer: systolic mm Hg  
  "dbp",        #integer: diastolic mm Hg
  "weight",     #numeric: weight in kg
  "height",     #numeric: height in cm
  "muac",       #numeric: mean upper arm circumfirence
  #clinical measures
  "glasgow",    #binary: glasgow score at inclusion, 1 if recorded, 9 if NA
  "glasgeye",   #categorical -- larger value more severe, scale different for less/over 4y
  "glasgmot",   #categorical as above
  "glasgverb",  #categorical as above
  "glasgtot",   #integer: sum of above 3 
  "blantyre",   #binary: blantyre score at inclusion, 1 if recorded, 9 if NA
  "blanteye",   #categorical -- larger value more severe
  "blantmot",   #categorical -- larger value more severe  
  "blantverb",  #categorical -- larger value more severe  
  "blanttot",   #integer: sum of above 3 
  "clinjaund",  #binary: jaundice  
  "clinhepato", #binary: hepatomegaly
  "clinspleno", #binary: slenomegaly
  "clinconv",   #binary: convulsions
  "clindehyd",  #binary: dehydration
  "clinoedem",  #binary: oedematous malnutrition
  "clinlymph",  #binary: lymphadenopathy
  "clinresp",   #binary: respiratory distress
  "clinablung", #binary: abnormal lung auscultation
  "clincyan",   #binary: cyanosis
  "clincapref", #binary: delayed capillary refill  
  "clincoldext", #binary: cold extremities
  "clinearinf",  #binary: ear infection  
  "clinanemia",  #binary decompensated anemia
  "clintonsil", #binary: tonsilitis
  "clinorcand", #binary: oral candidiasis
  "clinhemmor", #binary: skin sepsis
  "clinaids",   #binary: clinical suspicion of AIDS
  #diagnosis at inclusion - main
  "dimain",     #categorical: main diagnosis at inclusion: 1=meningitis, 2=cerbral malaria, 3=meningoencephalitis, 4=other
  "dimainsp",    #text: explanation of "other" above
  #diagnosis at inclusion - others
  "digast",     #binary: gastroenteritis  
  "diaids",     #binary: AIDS
  "dilrti",     #binary: lower respoiratory tract infection 
  "disepsis",   #binary: sepsis
  "dimalnut"    #binary: severe malnutrition
)

labels <- dat$diag

# 0=None
# 1=Malaria
# 2=Cerebral malaria	cerebmal
# 3=Bacterial mening
# 4=Bacteremia
# 5=Viral infections	- virus
# 6=Cryptococcal infection	- crypto
# 7=Tuberculous meningitis  - tblab
# 8=Mixed malaria-bacterial
# 9=Mixed viral-bacterial
# 10=Mixed viral-other
# 11 = None — mixed viral and cryptosporidium, perhaps misclassified “10”?

# NOTE -- COULD JUST RESTRICT TO THOSE FOR WHICH THERE WAS A CLEAR, SINGLE AGENT DIAGNOSIS
#labels[dat$diag > 4] <- NA
