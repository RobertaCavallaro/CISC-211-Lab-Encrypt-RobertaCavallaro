/*** asmEncrypt.s   ***/

#include <xc.h>

// Declare the following to be in data memory 
.data  

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Roberta Cavallaro"  
.align
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

// Define the globals so that the C code can access them
// (in this lab we return the pointer, so strictly speaking,
// does not really need to be defined as global)
// .global cipherText
.type cipherText,%gnu_unique_object

.align
 
@ NOTE: THIS .equ MUST MATCH THE #DEFINE IN main.c !!!!!
@ TODO: create a .h file that handles both C and assembly syntax for this definition
.equ CIPHER_TEXT_LEN, 200
 
// space allocated for cipherText: 200 bytes, prefilled with 0x2A
cipherText: .space CIPHER_TEXT_LEN,0x2A  

.align
 
.global cipherTextPtr
.type cipherTextPtr,%gnu_unique_object
cipherTextPtr: .word cipherText

// Tell the assembler that what follows is in instruction memory    
.text
.align

// Tell the assembler to allow both 16b and 32b extended Thumb instructions
.syntax unified

    
/********************************************************************
function name: asmEncrypt
function description:
     pointerToCipherText = asmEncrypt ( ptrToInputText , key )
     
where:
     input:
     ptrToInputText: location of first character in null-terminated
                     input string. Per calling convention, passed in via r0.
     key:            shift value (K). Range 0-25. Passed in via r1.
     
     output:
     pointerToCipherText: mem location (address) of first character of
                          encrypted text. Returned in r0
     
     function description: asmEncrypt reads each character of an input
                           string, uses a shifted alphabet to encrypt it,
                           and stores the new character value in memory
                           location beginning at "cipherText". After copying
                           a character to cipherText, a pointer is incremented 
                           so that the next letter is stored in the bext byte.
                           Only encrypt characters in the range [a-zA-Z].
                           Any other characters should just be copied as-is
                           without modifications
                           Stop processing the input string when a NULL (0)
                           byte is reached. Make sure to add the NULL at the
                           end of the cipherText string.
     
     notes:
        The return value will always be the mem location defined by
        the label "cipherText".
     
     
********************************************************************/    
.global asmEncrypt
.type asmEncrypt,%function
asmEncrypt:   

    /**save the caller's registers, as required by the ARM calling convention**/
    push {r4-r11,LR}
    
    /* YOUR asmEncrypt CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */

/** r0 for input text, r1 for key value K, cipherText label for mem location **/

    ldr r2, =cipherText /** load the address of cipherText into r2 **/
    
    mov r3, r2 /** Store cipherText address **/
    
    /** Make key between range 0-25 **/
    and r1, r1, #0xFF    /**  Get the lowest byte inly **/
    cmp r1, #26		 /**Comparison **/
    bge key_adjust       /** If r1 is grean than or equal 26 jump to key_adjust **/
    b process_loop       /** Otherwise jump to the process loop **/
    
key_adjust:
   
    mov r1, #0            /** Adjust key to be in range 0-25 **/
    
process_loop:    
    ldrb r4, [r0], #1    /** Load a byte from the input text and increment counter**/
    
    /** Check if we've reached the end encrypting **/
    cmp r4, #0
    beq done_encrypting
    
    /** Check for uppercase letter **/
    cmp r4, #'A'
    blt store_unchanged  /** If it is less than 'A'then is not a letter **/
    cmp r4, #'Z'
    ble encrypt_uppercase
    
    /** Check for lowercase letter **/
    cmp r4, #'a'
    blt store_unchanged  /** If it is less than 'a' and greater than 'Z' then it is not a letter **/
    cmp r4, #'z'
    ble encrypt_lowercase
    
    
    b store_unchanged/** The character is not a letter if here **/
    
encrypt_uppercase:
    /** Encrypt uppercase letter**/
    sub r4, r4, #'A'    /** Convert to 0-25 range **/
    add r4, r4, r1      /** Add key **/
    cmp r4, #25
    ble upper_in_range  /** If within range skip */
    sub r4, r4, #26     /** Wrap if it is needed **/
upper_in_range:
    add r4, r4, #'A'    /** Convert to standand mode**/
    b store_char
    
encrypt_lowercase:
    /** Encrypt lowercase letter **/
    sub r4, r4, #'a'    /** Convert to 0-25 range **/
    add r4, r4, r1      /** Add  key **/
    cmp r4, #25
    ble lower_in_range  /** If within range skip wrap **/
    sub r4, r4, #26     /** Wrapif it is needed **/
lower_in_range:
    add r4, r4, #'a'    /** Convert to standard mode */
    b store_char
    
store_unchanged:
    b store_char  /** Store the character unchanged **/
    
store_char:
    strb r4, [r2], #1   /** Store byte and increment pointer **/
    b process_loop      /** Go back to main loop **/
    
done_encrypting:
    
    mov r4, #0 /** Reached end of the input string so we add null terminator **/
    strb r4, [r2]
    
    
    ldr r0, =cipherText /** Return the pointer to cipherText **/
    
    /* YOUR asmEncrypt CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

    /**restore the caller's registers, as required by the ARM calling convention **/
    pop {r4-r11,LR}

    mov pc, lr	 /* asmEncrypt return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




