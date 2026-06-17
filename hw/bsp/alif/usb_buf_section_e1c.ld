/* usb_buf_section_e1c.ld */
/* E1C: Place USB DMA buffers in NON_SECURE0 region so the USB DMA controller
 * (a non-secure bus master) can access them. local_to_global() handles
 * address translation to global bus addresses. */
SECTION_PROLOGUE(.usb_ram,(NOLOAD), SUBALIGN(4096)) {
    __usb_ram_start = .;
    *(usb_dma_buf)
    __usb_ram_end = .;
} GROUP_LINK_IN(NON_SECURE0)
